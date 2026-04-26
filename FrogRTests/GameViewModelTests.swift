import XCTest
@testable import FrogR

final class GameViewModelTests: XCTestCase {

    var vm: GameViewModel!

    override func setUp() {
        super.setUp()
        vm = GameViewModel()
        // Clear any persisted high score for test isolation
        UserDefaults.standard.removeObject(forKey: "FrogR_HighScore")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "FrogR_HighScore")
        super.tearDown()
    }

    // MARK: - 1. formattedScore

    func testFormattedScore_zeroPaddedFiveDigits() {
        vm.startGame()
        XCTAssertEqual(vm.formattedScore, "00000")
    }

    func testFormattedScore_withScore() {
        vm.startGame()
        vm.engine.score = 42
        XCTAssertEqual(vm.formattedScore, "00042")
    }

    func testFormattedScore_largeScore() {
        vm.startGame()
        vm.engine.score = 12345
        XCTAssertEqual(vm.formattedScore, "12345")
    }

    func testFormattedScore_overflowStillWorks() {
        vm.startGame()
        vm.engine.score = 100000
        XCTAssertEqual(vm.formattedScore, "100000")
    }

    // MARK: - 2. livesDisplay

    func testLivesDisplay_threeLives() {
        vm.startGame()
        XCTAssertEqual(vm.livesDisplay, "🐸🐸🐸")
    }

    func testLivesDisplay_oneLives() {
        vm.startGame()
        vm.engine.lives = 1
        XCTAssertEqual(vm.livesDisplay, "🐸")
    }

    func testLivesDisplay_zeroLives() {
        vm.startGame()
        vm.engine.lives = 0
        XCTAssertEqual(vm.livesDisplay, "")
    }

    // MARK: - 3. currentLevelDisplay

    func testCurrentLevelDisplay_level1() {
        vm.startGame()
        XCTAssertEqual(vm.currentLevelDisplay, "Level 1")
    }

    func testCurrentLevelDisplay_level5() {
        vm.startGame()
        vm.engine.level = 5
        XCTAssertEqual(vm.currentLevelDisplay, "Level 5")
    }

    // MARK: - 4. handleSwipe

    func testHandleSwipe_up() {
        vm.startGame()
        let startRow = vm.engine.frog.row

        vm.handleSwipe(.up)
        XCTAssertEqual(vm.engine.frog.row, startRow - 1)
    }

    func testHandleSwipe_down() {
        vm.startGame()
        // Already at bottom row, should be no-op
        vm.handleSwipe(.down)
        XCTAssertEqual(vm.engine.frog.row, GridConstants.startRow)
    }

    func testHandleSwipe_left() {
        vm.startGame()
        let startCol = vm.engine.frog.col

        vm.handleSwipe(.left)
        XCTAssertEqual(vm.engine.frog.col, startCol - 1)
    }

    func testHandleSwipe_right() {
        vm.startGame()
        let startCol = vm.engine.frog.col

        vm.handleSwipe(.right)
        XCTAssertEqual(vm.engine.frog.col, startCol + 1)
    }

    // MARK: - 5. tick — deltaTime clamping

    func testTick_clampsDeltaTime() {
        vm.startGame()

        // Make all lanes safe so update doesn't kill the frog
        makeAllLanesSafe(engine: vm.engine)

        let t0 = Date()
        vm.tick(date: t0)

        // Simulate a 5-second gap (e.g. returning from background)
        let t1 = t0.addingTimeInterval(5.0)
        vm.tick(date: t1)

        // With clamping at 0.1s, elapsed should be ~0.1, not 5.0
        XCTAssertLessThanOrEqual(vm.engine.elapsedTime, 0.15,
                                  "Delta time should be clamped to max 0.1s")
    }

    func testTick_normalDelta() {
        vm.startGame()
        makeAllLanesSafe(engine: vm.engine)

        let t0 = Date()
        vm.tick(date: t0)

        let t1 = t0.addingTimeInterval(0.016) // ~60fps
        vm.tick(date: t1)

        XCTAssertGreaterThan(vm.engine.elapsedTime, 0.0)
        XCTAssertLessThan(vm.engine.elapsedTime, 0.05)
    }

    func testTick_whenNotPlaying_isNoop() {
        vm.startGame()
        vm.engine.gameState = .paused
        makeAllLanesSafe(engine: vm.engine)

        let t0 = Date()
        vm.tick(date: t0)
        let elapsed = vm.engine.elapsedTime

        let t1 = t0.addingTimeInterval(1.0)
        vm.tick(date: t1)

        XCTAssertEqual(vm.engine.elapsedTime, elapsed)
    }

    // MARK: - 6. High score persistence

    func testHighScore_persistsOnGameOver() {
        vm.startGame()
        vm.engine.score = 999

        // Trigger game over to persist
        vm.engine.lives = 1
        vm.engine.gameState = .gameOver
        vm.returnToMenu()

        XCTAssertEqual(vm.highScore, 999)
    }

    func testHighScore_doesNotDowngrade() {
        UserDefaults.standard.set(5000, forKey: "FrogR_HighScore")

        vm.startGame()
        vm.engine.score = 100
        vm.returnToMenu()

        XCTAssertEqual(vm.highScore, 5000)
    }

    func testHighScore_updatesWhenBeaten() {
        UserDefaults.standard.set(500, forKey: "FrogR_HighScore")

        vm.startGame()
        vm.engine.score = 600
        vm.returnToMenu()

        XCTAssertEqual(vm.highScore, 600)
    }

    // MARK: - 7. State passthrough

    func testStatePassthrough_gameState() {
        XCTAssertEqual(vm.gameState, .menu)

        vm.startGame()
        XCTAssertEqual(vm.gameState, .playing)

        vm.pauseGame()
        XCTAssertEqual(vm.gameState, .paused)

        vm.resumeGame()
        XCTAssertEqual(vm.gameState, .playing)
    }

    func testStatePassthrough_score() {
        vm.startGame()
        vm.engine.score = 777
        XCTAssertEqual(vm.score, 777)
    }

    func testStatePassthrough_lives() {
        vm.startGame()
        vm.engine.lives = 2
        XCTAssertEqual(vm.lives, 2)
    }

    func testStatePassthrough_level() {
        vm.startGame()
        vm.engine.level = 3
        XCTAssertEqual(vm.level, 3)
    }

    func testStatePassthrough_frog() {
        vm.startGame()
        vm.engine.frog.col = 7
        XCTAssertEqual(vm.frog.col, 7)
    }

    func testStatePassthrough_lanes() {
        vm.startGame()
        XCTAssertFalse(vm.lanes.isEmpty)
        XCTAssertEqual(vm.lanes.count, vm.engine.lanes.count)
    }

    func testStatePassthrough_goalsReached() {
        vm.startGame()
        vm.engine.goalsReached.insert(2)
        XCTAssertTrue(vm.goalsReached.contains(2))
    }

    // MARK: - Helpers

    private func makeAllLanesSafe(engine: GameEngine) {
        for i in engine.lanes.indices {
            let row = engine.lanes[i].row
            if engine.lanes[i].type != .goal && engine.lanes[i].type != .safe {
                engine.lanes[i] = Lane(type: .safe, row: row)
            }
        }
    }
}
