import Foundation
import SwiftUI

// MARK: - Diffculty
enum Difficulty: String, CaseIterable, Identifiable {
    case easy, medium, medHard = "med-hard", hard, master, legend, god
    
    var id: String { self.rawValue }
    
    var gridSize: Int {
        switch self {
        case .easy: return 6
        case .medium: return 7
        case .medHard: return 8
        case .hard: return 9
        case .master: return 10
        case .legend: return 11
        case .god: return 12
        }
    }
    
    var displayName: String {
        switch self {
        case .medHard: return "Med-Hard"
        case .god: return "????"
        default: return rawValue.capitalized
        }
    }
    
    var prefillRange: ClosedRange<Double> {
        switch self {
        case .easy: return 0.15...0.25
        case .medium: return 0.12...0.20
        case .medHard: return 0.10...0.18
        case .hard: return 0.08...0.15
        case .master: return 0.05...0.12
        case .legend: return 0.03...0.08
        case .god: return 0.00...0.05
        }
    }
    
    var levelClearReward: Int {
        switch self {
        case .easy: return 50
        case .medium: return 100
        case .medHard: return 150
        case .hard: return 200
        case .master: return 300
        case .legend: return 500
        case .god: return 1000
        }
    }
}

// MARK: - Game Entities
struct BlockPiece: Identifiable, Equatable {
    let id = UUID()
    let matrix: [[Int]] // 0 or 1
    let color: String   // e.g. "c-1", "c-god"
    
    // For level generation usage
    var targetX: Int?
    var targetY: Int?
}

struct Cell: Identifiable, Equatable {
    let id = UUID()
    var x: Int
    var y: Int
    var isFilled: Bool = false
    var color: String? = nil
    var isLocked: Bool = false // Preset blocks
    
    var isEmpty: Bool { !isFilled }
}

enum GameState {
    case playing
    case won
    case gameOver
}

struct MoveAction {
    let boardState: [[Cell]]
    let tray: [BlockPiece]
}
