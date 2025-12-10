import Foundation
import SwiftUI

// Determine if we can import ViewModels or if we need a protocol. 
// Assuming same target, we can forward declare or use GameViewModel if available.
// To be safe and clean, let's define the interface the Jokers need.

protocol GameContext: AnyObject {
    var coins: Int { get set }
    var tray: [BlockPiece] { get set }
    var board: [[Cell]] { get set }
    var currentGridSize: Int { get }
    
    // Actions needed by jokers
    func spendCoins(amount: Int) -> Bool
    func place(piece: BlockPiece, at x: Int, y: Int)
    func undoMove()
    
    // UI Triggers
    var showJokerModal: Bool { get set }
    
    // For calculating hints
    func canPlace(piece: BlockPiece, at x: Int, y: Int) -> Bool
    func findPlacement(for piece: BlockPiece) -> (x: Int, y: Int)?
}

protocol JokerProtocol {
    var id: JokerType { get }
    var name: String { get }
    var icon: String { get }      // SF Symbol or Emoji
    var color: Color { get }      // Button color
    var cost: Int { get }
    
    // Execute the joker's action. 
    // Returns true if the action was successfully triggered/completed.
    func execute(context: GameContext) -> Bool
}

enum JokerType: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case undo, hint, piece
}
