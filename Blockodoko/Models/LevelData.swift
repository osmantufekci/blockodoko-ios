//
//  LevelData.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//
import Foundation

struct LevelData: Identifiable, Codable {
    let id: Int                 // Level Numarası (1, 2, 3...)
    let difficulty: Difficulty  // Enum (Easy, Medium vs.)
    let seed: String            // Üretim kodu
    let targetPieces: Int       // Bu level için kaç parça yerleştirilmeli?

    var title: String {
        return "Level \(id)"
    }
}
