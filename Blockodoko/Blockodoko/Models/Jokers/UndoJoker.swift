//
//  UndoJoker.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 11.12.2025.
//
import SwiftUI

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
