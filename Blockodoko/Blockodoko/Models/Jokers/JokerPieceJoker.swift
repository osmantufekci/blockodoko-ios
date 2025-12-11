//
//  JokerPieceJoker.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 11.12.2025.
//
import SwiftUI

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
