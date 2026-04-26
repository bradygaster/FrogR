import SwiftUI

@Observable
final class GameViewModel {

    // MARK: - Engine

    let engine = GameEngine()

    // MARK: - High Score

    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "FrogR_HighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "FrogR_HighScore") }
    }

    private var lastUpdateTime: Date?

    // MARK: - Computed Display Properties

    var gameState: GameState { engine.gameState }
    var score: Int { engine.score }
    var lives: Int { engine.lives }
    var level: Int { engine.level }
    var frog: Frog { engine.frog }
    var lanes: [Lane] { engine.lanes }
    var goalsReached: Set<Int> { engine.goalsReached }

    var formattedScore: String {
        String(format: "%05d", engine.score)
    }

    var livesDisplay: String {
        String(repeating: "🐸", count: max(engine.lives, 0))
    }

    var currentLevelDisplay: String {
        "Level \(engine.level)"
    }

    // MARK: - Actions

    func startGame() {
        lastUpdateTime = nil
        engine.startGame()
    }

    func pauseGame() {
        engine.pauseGame()
    }

    func resumeGame() {
        lastUpdateTime = nil
        engine.resumeGame()
    }

    func returnToMenu() {
        updateHighScore()
        engine.returnToMenu()
    }

    func restartGame() {
        updateHighScore()
        lastUpdateTime = nil
        engine.restartGame()
    }

    // MARK: - Input

    func handleSwipe(_ direction: Direction) {
        engine.moveFrog(direction)
    }

    // MARK: - Game Loop

    func tick(date: Date) {
        guard engine.gameState == .playing else {
            lastUpdateTime = nil
            return
        }

        if let last = lastUpdateTime {
            let dt = date.timeIntervalSince(last)
            // Clamp delta to avoid huge jumps (e.g. after backgrounding)
            let clampedDt = min(dt, 0.1)
            engine.update(deltaTime: clampedDt)
        }
        lastUpdateTime = date

        if engine.gameState == .gameOver {
            updateHighScore()
        }
    }

    // MARK: - High Score Persistence

    private func updateHighScore() {
        if engine.score > highScore {
            highScore = engine.score
        }
    }
}
