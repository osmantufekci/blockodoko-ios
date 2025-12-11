//
//  HintJoker.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 11.12.2025.
//
import SwiftUI

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