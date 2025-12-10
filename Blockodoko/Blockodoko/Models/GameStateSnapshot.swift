//
//  GameStateSnapshot.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//


struct GameStateSnapshot {
    let board: [[Cell]]
    let tray: [BlockPiece]
    let piecesPlacedCount: Int
    // Eğer puan sistemi kullanıyorsan score'u da eklemelisin
}