//
//  LevelLibrary.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//
import Foundation

struct LevelLibrary {
    // Tüm levelları burada sırayla tanımlıyoruz
    static let allLevels: [LevelData] = [
        
        // --- SECTION 1: BASICS (EASY) ---
        LevelData(id: 0, difficulty: .easy, seed: "LEVEL_00_START", targetPieces: 10),
        LevelData(id: 1, difficulty: .easy, seed: "LEVEL_01_START", targetPieces: 10),
        LevelData(id: 2, difficulty: .easy, seed: "LEVEL_02_BASIC", targetPieces: 12),
        LevelData(id: 3, difficulty: .easy, seed: "LEVEL_03_LEARN", targetPieces: 14),
        LevelData(id: 4, difficulty: .easy, seed: "LEVEL_04_WARM",  targetPieces: 15),

        // --- SECTION 2: GETTING SERIOUS (MEDIUM) ---
        LevelData(id: 5, difficulty: .medium, seed: "LEVEL_05_STEP", targetPieces: 18),
        LevelData(id: 6, difficulty: .medium, seed: "LEVEL_06_PATH", targetPieces: 20),
        LevelData(id: 7, difficulty: .medium, seed: "LEVEL_07_CLIMB", targetPieces: 20),
        LevelData(id: 8, difficulty: .medium, seed: "LEVEL_08_PEAK", targetPieces: 22),

        // --- SECTION 3: CHALLENGE (MED-HARD) ---
        LevelData(id: 9,  difficulty: .medHard, seed: "LEVEL_09_HARDER", targetPieces: 25),
        LevelData(id: 10, difficulty: .medHard, seed: "LEVEL_10_TOUGH", targetPieces: 25),

        // --- SECTION 4: MASTER (HARD) ---
        LevelData(id: 11, difficulty: .hard, seed: "LEVEL_11_CRUSH", targetPieces: 30),
        LevelData(id: 12, difficulty: .hard, seed: "LEVEL_12_FINAL", targetPieces: 35)
    ]
    
    // Level numarasına göre veriyi çeken yardımcı fonksiyon
    static func getLevel(number: Int) -> LevelData? {
        return allLevels.first { $0.id == number }
    }
    
    // Toplam level sayısını öğrenmek için
    static var totalLevels: Int {
        return allLevels.count
    }
}
