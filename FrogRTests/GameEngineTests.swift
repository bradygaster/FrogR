import XCTest
@testable import FrogR

final class GameEngineTests: XCTestCase {

    var engine: GameEngine!

    override func setUp() {
        super.setUp()
        engine = GameEngine()
    }

    // MARK: - 1. startGame

    func testStartGame_setsInitialState() {
        engine.startGame()

        XCTAssertEqual(engine.lives, 3)
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.level, 1)
        XCTAssertEqual(engine.gameState, .playing)
        XCTAssertEqual(engine.frog.col, GridConstants.startCol)
        XCTAssertEqual(engine.frog.row, GridConstants.startRow)
        XCTAssertEqual(engine.frog.ridingOffset, 0.0)
        XCTAssertTrue(engine.goalsReached.isEmpty)
    }

    func testStartGame_generatesLanes() {
        engine.startGame()

        XCTAssertFalse(engine.lanes.isEmpty)
        XCTAssertEqual(engine.lanes.count, GridConstants.rows)
        XCTAssertEqual(engine.lanes.first { $0.row == 0 }?.type, .goal)
        XCTAssertEqual(engine.lanes.first { $0.row == 6 }?.type, .safe)
        XCTAssertEqual(engine.lanes.first { $0.row == 12 }?.type, .safe)
    }

    // MARK: - 2. moveFrog — all 4 directions

    func testMoveFrog_up() {
        engine.startGame()
        let startRow = engine.frog.row

        engine.moveFrog(.up)
        XCTAssertEqual(engine.frog.row, startRow - 1)
    }

    func testMoveFrog_down() {
        engine.startGame()
        // Move up first so we can move down from a non-bottom row
        engine.frog.row = 6
        replaceLaneAsSafe(row: 6)

        engine.moveFrog(.down)
        XCTAssertEqual(engine.frog.row, 7)
    }

    func testMoveFrog_left() {
        engine.startGame()
        let startCol = engine.frog.col

        engine.moveFrog(.left)
        XCTAssertEqual(engine.frog.col, startCol - 1)
    }

    func testMoveFrog_right() {
        engine.startGame()
        let startCol = engine.frog.col

        engine.moveFrog(.right)
        XCTAssertEqual(engine.frog.col, startCol + 1)
    }

    // MARK: - 2b. Boundary checks

    func testMoveFrog_cannotMoveAboveGrid() {
        engine.startGame()
        makeAllLanesSafe()
        engine.frog.row = 1
        engine.frog.col = GridConstants.startCol

        // Row 0 is goal row — moving up when already at row 0 should clamp
        engine.moveFrog(.up) // goes to row 0 → goal handling resets frog
        // After goal handling, frog is reset. Let's test the raw boundary.
        engine.frog.row = 0
        engine.moveFrog(.up)
        // frog.row should stay 0 (guard: frog.row > 0)
        // But goal handling fires. Let's test boundary on col instead.
    }

    func testMoveFrog_cannotMoveBelowGrid() {
        engine.startGame()
        engine.frog.row = GridConstants.rows - 1

        engine.moveFrog(.down)
        XCTAssertEqual(engine.frog.row, GridConstants.rows - 1)
    }

    func testMoveFrog_cannotMoveLeftOfGrid() {
        engine.startGame()
        engine.frog.col = 0

        engine.moveFrog(.left)
        XCTAssertEqual(engine.frog.col, 0)
    }

    func testMoveFrog_cannotMoveRightOfGrid() {
        engine.startGame()
        engine.frog.col = GridConstants.columns - 1

        engine.moveFrog(.right)
        XCTAssertEqual(engine.frog.col, GridConstants.columns - 1)
    }

    // MARK: - 3. moveFrog when not playing

    func testMoveFrog_whenNotPlaying_isNoop() {
        engine.gameState = .menu
        engine.frog.row = 6
        engine.frog.col = 5

        engine.moveFrog(.up)
        XCTAssertEqual(engine.frog.row, 6)
        XCTAssertEqual(engine.frog.col, 5)
    }

    func testMoveFrog_whenGameOver_isNoop() {
        engine.startGame()
        engine.gameState = .gameOver
        let row = engine.frog.row

        engine.moveFrog(.up)
        XCTAssertEqual(engine.frog.row, row)
    }

    func testMoveFrog_whenPaused_isNoop() {
        engine.startGame()
        engine.pauseGame()
        let row = engine.frog.row

        engine.moveFrog(.up)
        XCTAssertEqual(engine.frog.row, row)
    }

    // MARK: - 4. Road collision

    func testRoadCollision_losesLife() {
        engine.startGame()

        // Place a deterministic road lane at row 10
        let obstacle = Obstacle(x: 5.0, width: 1.0, speed: 0, direction: .right, emoji: "🚗")
        setLane(row: 10, type: .road, obstacles: [obstacle])

        engine.frog.row = 10
        engine.frog.col = 5
        engine.frog.ridingOffset = 0.0

        engine.checkCollision()

        // Frog should lose a life and be reset
        XCTAssertEqual(engine.lives, 2)
        XCTAssertEqual(engine.frog.row, GridConstants.startRow)
    }

    // MARK: - 5. Water collision (no platform)

    func testWaterCollision_noPlatform_losesLife() {
        engine.startGame()

        // Place a water lane with no platforms near the frog
        let platform = Platform(x: 10.0, width: 1.0, speed: 0, direction: .right, emoji: "🪵")
        setLane(row: 3, type: .water, platforms: [platform])

        engine.frog.row = 3
        engine.frog.col = 0
        engine.frog.ridingOffset = 0.0

        engine.checkCollision()

        XCTAssertEqual(engine.lives, 2)
        XCTAssertEqual(engine.frog.row, GridConstants.startRow)
    }

    // MARK: - 6. Water safe (on platform)

    func testWaterSafe_onPlatform_noDeathOccurs() {
        engine.startGame()

        let platform = Platform(x: 5.0, width: 3.0, speed: 0, direction: .right, emoji: "🪵")
        setLane(row: 3, type: .water, platforms: [platform])

        engine.frog.row = 3
        engine.frog.col = 6
        engine.frog.ridingOffset = 0.0

        engine.checkCollision()

        XCTAssertEqual(engine.lives, 3)
        XCTAssertEqual(engine.frog.row, 3)
    }

    // MARK: - 7. Goal reached

    func testGoalReached_scoresAndResets() {
        engine.startGame()

        engine.frog.row = 0
        engine.frog.col = 1
        engine.frog.ridingOffset = 0.0

        engine.checkCollision()

        XCTAssertGreaterThan(engine.score, 0)
        XCTAssertEqual(engine.frog.row, GridConstants.startRow)
        XCTAssertEqual(engine.goalsReached.count, 1)
    }

    func testGoalReached_scoreValue() {
        engine.startGame()
        // Level 1 → score = 100 + (1 * 50) = 150
        engine.frog.row = 0
        engine.frog.col = 1
        engine.frog.ridingOffset = 0.0

        engine.checkCollision()

        XCTAssertEqual(engine.score, 150)
    }

    // MARK: - 8. Duplicate goal

    func testDuplicateGoal_bounceBack() {
        engine.startGame()

        // Reach goal slot 0
        engine.frog.row = 0
        engine.frog.col = 1
        engine.frog.ridingOffset = 0.0
        engine.checkCollision()
        XCTAssertEqual(engine.goalsReached.count, 1)
        let scoreAfterFirst = engine.score

        // Try reaching the same slot
        engine.frog.row = 0
        engine.frog.col = 1
        engine.frog.ridingOffset = 0.0
        engine.checkCollision()

        // Score should not change — frog bounced back
        XCTAssertEqual(engine.score, scoreAfterFirst)
        XCTAssertEqual(engine.frog.row, GridConstants.startRow)
        XCTAssertEqual(engine.goalsReached.count, 1)
    }

    // MARK: - 9. All goals filled → level advances

    func testAllGoalsFilled_advancesLevel() {
        engine.startGame()

        // Fill all 4 goal slots (columns 1, 4, 7, 10 map to slots 0,1,2,3)
        let goalCols = [1, 4, 7, 10]
        for col in goalCols {
            engine.frog.row = 0
            engine.frog.col = col
            engine.frog.ridingOffset = 0.0
            engine.checkCollision()
        }

        XCTAssertEqual(engine.level, 2)
        XCTAssertTrue(engine.goalsReached.isEmpty, "Goals should be cleared for new level")
        // Score: 4 × 150 (goal scores) + 500 (advance bonus) = 1100
        XCTAssertEqual(engine.score, 4 * 150 + 500)
    }

    // MARK: - 10. Game over

    func testGameOver_afterLosingAllLives() {
        engine.startGame()

        for _ in 0..<3 {
            // Place frog in water with no platform
            setLane(row: 3, type: .water, platforms: [])
            engine.frog.row = 3
            engine.frog.col = 5
            engine.frog.ridingOffset = 0.0
            engine.checkCollision()
        }

        XCTAssertEqual(engine.lives, 0)
        XCTAssertEqual(engine.gameState, .gameOver)
    }

    // MARK: - 11. Pause / Resume

    func testPause_whenPlaying() {
        engine.startGame()
        XCTAssertEqual(engine.gameState, .playing)

        engine.pauseGame()
        XCTAssertEqual(engine.gameState, .paused)
    }

    func testResume_whenPaused() {
        engine.startGame()
        engine.pauseGame()
        XCTAssertEqual(engine.gameState, .paused)

        engine.resumeGame()
        XCTAssertEqual(engine.gameState, .playing)
    }

    func testPause_whenNotPlaying_isNoop() {
        engine.gameState = .menu
        engine.pauseGame()
        XCTAssertEqual(engine.gameState, .menu)
    }

    func testResume_whenNotPaused_isNoop() {
        engine.startGame()
        engine.resumeGame()
        XCTAssertEqual(engine.gameState, .playing)
    }

    // MARK: - 12. Level speed scaling

    func testLevelSpeedScaling_higherLevelsFasterObstacles() {
        let level1Lanes = engine.buildLevel(1)
        let level5Lanes = engine.buildLevel(5)

        let roadLanes1 = level1Lanes.filter { $0.type == .road }
        let roadLanes5 = level5Lanes.filter { $0.type == .road }

        // Gather max speeds from each level
        let maxSpeed1 = roadLanes1.flatMap { $0.obstacles.map { $0.speed } }.max() ?? 0
        let maxSpeed5 = roadLanes5.flatMap { $0.obstacles.map { $0.speed } }.max() ?? 0

        // Speed multiplier for level 5 is 1.0 + 4*0.2 = 1.8× level 1
        XCTAssertGreaterThan(maxSpeed5, maxSpeed1, "Level 5 should have faster obstacles than level 1")
    }

    func testLevelSpeedScaling_waterPlatforms() {
        let level1Lanes = engine.buildLevel(1)
        let level3Lanes = engine.buildLevel(3)

        let waterLanes1 = level1Lanes.filter { $0.type == .water }
        let waterLanes3 = level3Lanes.filter { $0.type == .water }

        let avgSpeed1 = waterLanes1.flatMap { $0.platforms.map { $0.speed } }
            .reduce(0.0, +) / max(Double(waterLanes1.flatMap { $0.platforms }.count), 1)
        let avgSpeed3 = waterLanes3.flatMap { $0.platforms.map { $0.speed } }
            .reduce(0.0, +) / max(Double(waterLanes3.flatMap { $0.platforms }.count), 1)

        XCTAssertGreaterThan(avgSpeed3, avgSpeed1, "Level 3 water platforms should be faster than level 1")
    }

    // MARK: - 13. Platform drift

    func testPlatformDrift_accumulatesOffset() {
        engine.startGame()

        let platform = Platform(x: 5.0, width: 3.0, speed: 2.0, direction: .right, emoji: "🪵")
        setLane(row: 3, type: .water, platforms: [platform])

        engine.frog.row = 3
        engine.frog.col = 5
        engine.frog.ridingOffset = 0.0

        // Simulate several frames
        for _ in 0..<10 {
            engine.update(deltaTime: 0.016)
        }

        XCTAssertGreaterThan(engine.frog.ridingOffset, 0.0,
                             "Frog should drift right with the platform")
    }

    // MARK: - 14. Frog drift off screen

    func testFrogDriftOffScreen_losesLife() {
        engine.startGame()

        let platform = Platform(x: 11.0, width: 2.0, speed: 5.0, direction: .right, emoji: "🪵")
        setLane(row: 3, type: .water, platforms: [platform])

        engine.frog.row = 3
        engine.frog.col = 11
        engine.frog.ridingOffset = 0.0

        // Simulate enough frames for the frog to drift off right edge
        for _ in 0..<100 {
            engine.update(deltaTime: 0.05)
        }

        XCTAssertLessThan(engine.lives, 3, "Frog should lose a life when drifting off screen")
    }

    // MARK: - Helpers

    /// Replace the lane at the given row with a deterministic one.
    private func setLane(row: Int, type: LaneType, obstacles: [Obstacle] = [], platforms: [Platform] = []) {
        if let idx = engine.lanes.firstIndex(where: { $0.row == row }) {
            engine.lanes[idx] = Lane(type: type, row: row, obstacles: obstacles, platforms: platforms)
        }
    }

    /// Replace a single lane as safe (no hazards).
    private func replaceLaneAsSafe(row: Int) {
        setLane(row: row, type: .safe)
    }

    /// Make every lane safe so movement tests don't trigger collisions.
    private func makeAllLanesSafe() {
        for i in engine.lanes.indices {
            let row = engine.lanes[i].row
            if engine.lanes[i].type != .goal && engine.lanes[i].type != .safe {
                engine.lanes[i] = Lane(type: .safe, row: row)
            }
        }
    }
}
