import Foundation

@Observable
final class GameEngine {

    // MARK: - Published State

    var frog = Frog(col: GridConstants.startCol, row: GridConstants.startRow, lives: 3)
    var lanes: [Lane] = []
    var score: Int = 0
    var lives: Int = 3
    var level: Int = 1
    var gameState: GameState = .menu
    var elapsedTime: TimeInterval = 0
    var goalsReached: Set<Int> = []

    private let totalGoalSlots = 4

    // MARK: - Game Lifecycle

    func startGame() {
        level = 1
        score = 0
        lives = 3
        elapsedTime = 0
        goalsReached = []
        lanes = buildLevel(level)
        resetFrogPosition()
        gameState = .playing
    }

    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
    }

    func restartGame() {
        startGame()
    }

    func returnToMenu() {
        gameState = .menu
    }

    // MARK: - Frog Movement

    func moveFrog(_ direction: Direction) {
        guard gameState == .playing else { return }

        // Clear riding offset when the player actively moves
        frog.ridingOffset = 0.0

        switch direction {
        case .up:
            if frog.row > 0 { frog.row -= 1 }
        case .down:
            if frog.row < GridConstants.rows - 1 { frog.row += 1 }
        case .left:
            if frog.col > 0 { frog.col -= 1 }
        case .right:
            if frog.col < GridConstants.columns - 1 { frog.col += 1 }
        }

        // Immediate collision check after move
        checkCollision()
    }

    // MARK: - Frame Update

    func update(deltaTime: TimeInterval) {
        guard gameState == .playing else { return }
        guard deltaTime > 0 else { return }  // no-op writes trigger @Observable
        elapsedTime += deltaTime

        moveItems(deltaTime: deltaTime)
        applyPlatformDrift(deltaTime: deltaTime)
        checkCollision()
    }

    // MARK: - Move Obstacles & Platforms

    private func moveItems(deltaTime: TimeInterval) {
        let cols = Double(GridConstants.columns)

        for i in lanes.indices {
            // Move obstacles
            for j in lanes[i].obstacles.indices {
                let obs = lanes[i].obstacles[j]
                let dx = obs.speed * deltaTime * (obs.direction == .right ? 1.0 : -1.0)
                lanes[i].obstacles[j].x += dx

                // Wrap around
                if lanes[i].obstacles[j].x > cols + 1 {
                    lanes[i].obstacles[j].x = -obs.width
                } else if lanes[i].obstacles[j].x + obs.width < -1 {
                    lanes[i].obstacles[j].x = cols + 1
                }
            }

            // Move platforms
            for j in lanes[i].platforms.indices {
                let plat = lanes[i].platforms[j]
                let dx = plat.speed * deltaTime * (plat.direction == .right ? 1.0 : -1.0)
                lanes[i].platforms[j].x += dx

                // Wrap around
                if lanes[i].platforms[j].x > cols + 1 {
                    lanes[i].platforms[j].x = -plat.width
                } else if lanes[i].platforms[j].x + plat.width < -1 {
                    lanes[i].platforms[j].x = cols + 1
                }
            }
        }
    }

    /// When frog is on a water lane riding a platform, drift with it
    private func applyPlatformDrift(deltaTime: TimeInterval) {
        let lane = lanes.first { $0.row == frog.row }
        guard let lane, lane.type == .water else {
            frog.ridingOffset = 0.0
            return
        }

        let frogX = frog.effectiveCol
        for plat in lane.platforms {
            if frogX >= plat.x - 0.3 && frogX < plat.x + plat.width + 0.3 {
                let dx = plat.speed * deltaTime * (plat.direction == .right ? 1.0 : -1.0)
                frog.ridingOffset += dx
                return
            }
        }
    }

    // MARK: - Collision Detection

    func checkCollision() {
        let currentLane = lanes.first { $0.row == frog.row }

        // Goal row
        if frog.row == GridConstants.goalRow {
            handleGoalReached()
            return
        }

        guard let lane = currentLane else { return }

        switch lane.type {
        case .road:
            checkRoadCollision(lane)
        case .water:
            checkWaterCollision(lane)
        case .safe, .goal:
            break
        }

        // Check if frog drifted off screen
        if frog.effectiveCol < -0.5 || frog.effectiveCol >= Double(GridConstants.columns) + 0.5 {
            loseLife()
        }
    }

    private func checkRoadCollision(_ lane: Lane) {
        let frogX = frog.effectiveCol
        for obs in lane.obstacles {
            let hitBox = obs.x ..< (obs.x + obs.width)
            if hitBox.contains(frogX) {
                loseLife()
                return
            }
        }
    }

    private func checkWaterCollision(_ lane: Lane) {
        let frogX = frog.effectiveCol
        var onPlatform = false
        for plat in lane.platforms {
            if frogX >= plat.x - 0.3 && frogX < plat.x + plat.width + 0.3 {
                onPlatform = true
                break
            }
        }
        if !onPlatform {
            loseLife()
        }
    }

    // MARK: - Goal Handling

    private func handleGoalReached() {
        // Map frog column to nearest goal slot
        let slotWidth = Double(GridConstants.columns) / Double(totalGoalSlots)
        let slot = Int(frog.effectiveCol / slotWidth)
        let clampedSlot = min(max(slot, 0), totalGoalSlots - 1)

        if goalsReached.contains(clampedSlot) {
            // Already filled — bounce back
            frog.row = GridConstants.startRow
            frog.ridingOffset = 0.0
            return
        }

        goalsReached.insert(clampedSlot)
        score += 100 + (level * 50)
        resetFrogPosition()

        if goalsReached.count >= totalGoalSlots {
            advanceLevel()
        }
    }

    private func advanceLevel() {
        level += 1
        score += 500
        goalsReached = []
        lanes = buildLevel(level)
        resetFrogPosition()
    }

    // MARK: - Lose Life

    private func loseLife() {
        lives -= 1
        frog.lives = lives
        if lives <= 0 {
            gameState = .gameOver
        } else {
            resetFrogPosition()
        }
    }

    private func resetFrogPosition() {
        frog.col = GridConstants.startCol
        frog.row = GridConstants.startRow
        frog.ridingOffset = 0.0
        frog.lives = lives
    }

    // MARK: - Level Builder

    func buildLevel(_ number: Int) -> [Lane] {
        let speedMultiplier = 1.0 + Double(number - 1) * 0.2
        var result: [Lane] = []

        // Row 0 — Goal
        result.append(Lane(type: .goal, row: 0))

        // Rows 1–5 — Water with platforms
        for row in 1...5 {
            let dir: Direction = row.isMultiple(of: 2) ? .right : .left
            let speed = Double.random(in: 1.5...3.0) * speedMultiplier
            let emoji = row.isMultiple(of: 2) ? "🪵" : "🐢"
            let platWidth = Double.random(in: 2.0...4.0)
            var platforms: [Platform] = []

            let count = Int.random(in: 2...3)
            let spacing = Double(GridConstants.columns) / Double(count)
            for i in 0..<count {
                platforms.append(Platform(
                    x: Double(i) * spacing + Double.random(in: -0.5...0.5),
                    width: platWidth,
                    speed: speed,
                    direction: dir,
                    emoji: emoji
                ))
            }

            result.append(Lane(type: .water, row: row, platforms: platforms))
        }

        // Row 6 — Safe median
        result.append(Lane(type: .safe, row: 6))

        // Rows 7–11 — Road with obstacles
        let carEmojis = ["🚗", "🚙", "🚌", "🚛"]
        for row in 7...11 {
            let dir: Direction = row.isMultiple(of: 2) ? .right : .left
            let speed = Double.random(in: 2.0...4.5) * speedMultiplier
            let emoji = carEmojis[(row - 7) % carEmojis.count]
            let obsWidth = emoji == "🚌" || emoji == "🚛" ? 2.0 : 1.0
            var obstacles: [Obstacle] = []

            let count = Int.random(in: 2...4)
            let spacing = Double(GridConstants.columns) / Double(count)
            for i in 0..<count {
                obstacles.append(Obstacle(
                    x: Double(i) * spacing + Double.random(in: -0.5...0.5),
                    width: obsWidth,
                    speed: speed,
                    direction: dir,
                    emoji: emoji
                ))
            }

            result.append(Lane(type: .road, row: row, obstacles: obstacles))
        }

        // Row 12 — Start safe zone
        result.append(Lane(type: .safe, row: 12))

        return result.sorted { $0.row < $1.row }
    }
}
