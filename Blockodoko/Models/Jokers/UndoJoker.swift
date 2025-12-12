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
    let cost = 100
    
    func execute(context: GameContext) -> Bool {
        // Simple Undo
        // Ensure can undo?
        context.undoMove()
        return true
    }
}
