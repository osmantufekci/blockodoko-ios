//
//  LevelManager.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 12.12.2025.
//
import Foundation
import FirebaseFirestore
import Combine

final class LevelManager: ObservableObject {
    static let shared = LevelManager()
    private let db = Firestore.firestore()
    
    @Published var levels: [LevelData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let fallbackLevels = LevelLibrary.allLevels

    func fetchLevels(completed: @escaping () -> Void) {
        isLoading = true
        db.collection("levels").order(by: "id").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching levels: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    if self.levels.isEmpty { self.levels = self.fallbackLevels }
                    completed()
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.levels = self.fallbackLevels
                    completed()
                    return
                }

                self.levels = documents.compactMap { doc -> LevelData? in
                    completed()
                    return try? doc.data(as: LevelData.self)
                }
                
                print("🔥 Firebase'den \(self.levels.count) adet level başarıyla yüklendi!")
            }
        }
    }

    // MARK: ~ Admin Method
    func uploadStaticLevelsToFirebase() {
        let levelsToUpload = fallbackLevels
        
        for level in levelsToUpload {
            let docID = "level_\(level.id)"
            do {
                try db.collection("levels").document(docID).setData(from: level)
                print("✅ Level \(level.id) yüklendi.")
            } catch {
                print("❌ Level \(level.id) yüklenirken hata: \(error)")
            }
        }
    }

    func getLevel(number: Int) -> LevelData? {
        return levels.first { $0.id == number }
    }

    func getRewardData(number: Int) -> Int? {
        return levels.first { $0.id == number }?.difficulty.levelClearReward
    }
}
