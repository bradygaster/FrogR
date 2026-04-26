import Foundation

// MARK: - Game State

enum GameState: Equatable {
    case menu
    case playing
    case paused
    case gameOver
    case won
}

// MARK: - Direction

enum Direction: Equatable {
    case up, down, left, right
}

// MARK: - Lane Type

enum LaneType: Equatable {
    case road
    case water
    case safe
    case goal

    var color: String {
        switch self {
        case .road: return "road"
        case .water: return "water"
        case .safe: return "safe"
        case .goal: return "goal"
        }
    }
}

// MARK: - Obstacle (cars/trucks on roads)

struct Obstacle: Identifiable, Equatable {
    let id = UUID()
    var x: Double
    let width: Double
    let speed: Double
    let direction: Direction
    let emoji: String

    static func == (lhs: Obstacle, rhs: Obstacle) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Platform (logs/turtles on water)

struct Platform: Identifiable, Equatable {
    let id = UUID()
    var x: Double
    let width: Double
    let speed: Double
    let direction: Direction
    let emoji: String

    static func == (lhs: Platform, rhs: Platform) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Lane

struct Lane: Identifiable, Equatable {
    let id = UUID()
    let type: LaneType
    let row: Int
    var obstacles: [Obstacle]
    var platforms: [Platform]

    init(type: LaneType, row: Int, obstacles: [Obstacle] = [], platforms: [Platform] = []) {
        self.type = type
        self.row = row
        self.obstacles = obstacles
        self.platforms = platforms
    }

    static func == (lhs: Lane, rhs: Lane) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Frog

struct Frog: Equatable {
    var col: Int
    var row: Int
    var lives: Int
    /// Fractional x-offset applied when riding a platform (in columns)
    var ridingOffset: Double = 0.0

    var effectiveCol: Double {
        Double(col) + ridingOffset
    }
}

// MARK: - Game Level

struct GameLevel {
    let number: Int
    var lanes: [Lane]
}

// MARK: - Grid Constants

enum GridConstants {
    static let columns = 12
    static let rows = 13
    static let startRow = 12
    static let startCol = 5
    static let goalRow = 0
    static let waterRowRange = 1...5
    static let safeRow = 6
    static let roadRowRange = 7...11
}
