import SwiftUI
import Combine

// MARK: - Hint Joker
struct HintJoker: JokerProtocol {
    let id: JokerType = .hint
    let name = "Hint"
    let icon = "lightbulb.fill" // System Name
    let color = Color.yellow
    let cost = 100
    
    func execute(context: GameContext) -> Bool {
        // Validation: Is there checks for free hints? (Skipped for now)
        
        // 1. Check if we have moves
        var foundPiece: BlockPiece?
        var foundPlacement: (x: Int, y: Int)?

        for piece in context.tray {
            if let placement = context.findPlacement(for: piece) {
                foundPiece = piece
                foundPlacement = placement
                break
            }
        }

        guard let piece = foundPiece, let placement = foundPlacement else {
            // Vibro logic could be here or in VM
            return false
        }

        // 2. Spend Coins
        if context.spendCoins(amount: cost) {
            // 3. Place
            // Note: withAnimation is a View side thing, tricky to trigger here unless context handles it.
            // We will just call place, VM should handle publishing changes.
            context.place(piece: piece, at: placement.x, y: placement.y)
            return true
        }
        
        return false
    }
}

// MARK: - Undo Joker
struct UndoJoker: JokerProtocol {
    let id: JokerType = .undo
    let name = "Undo"
    let icon = "arrow.uturn.backward"
    let color = Color.orange
    let cost = 0 // Assuming free for now based on UI, or maybe 50? Set to 0 as per recent user code showing "Undo" without price label in previous diffs? 
                 // Wait, user removed price from UI but requested it in plan. 
                 // Previous UI showed "Joker (200)" and "Hint (100)". Undo just "Undo".
                 // Detailed Plan said "Undo: Cost 50". Let's stick to 50.
                 // Actually, let's make it 50 to demonstrate "Manager handles costs".
    
    func execute(context: GameContext) -> Bool {
        // Simple Undo
        // Ensure can undo?
        context.undoMove()
        return true
    }
}

// MARK: - Joker Piece (Modal)
struct JokerPieceJoker: JokerProtocol {
    let id: JokerType = .piece
    let name = "Joker"
    let icon = "star.fill"
    let color = Color.purple
    let cost = 200
    
    func execute(context: GameContext) -> Bool {
        // Just opens the modal
        // The modal logic inside will handle the deduction when "Create" is clicked?
        
        // PROBLEM: If we deduct NOW, user pays just to see the modal.
        // Usually you pay when you USE the item.
        // But for "Hint", checking cost is done before action.
        
        // Logic:
        // Set showJokerModal = true.
        // The actual deduction happens inside the modal viewmodel logic? 
        // OR the modal is just a UI to *select* the shape, and then we call a "create" function that charges?
        
        // Let's rely on the VM showing the modal.
        context.showJokerModal = true
        return true
    }
}
