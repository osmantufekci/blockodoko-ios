//
//  HapticManager.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//
import UIKit

class HapticManager {
    // Singleton instance: Her yerden HapticManager.shared.action() diye çağırmak için
    static let shared = HapticManager()

    private init() {} // Dışarıdan yeni instance yaratılmasını engeller

    // MARK: - Temel Oynanış (Gameplay)

    // Parçayı eline aldığında (Hafif bir 'tık' hissi)
    func liftPiece() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    // Parçayı yerine oturtunca (Tok bir 'tak' hissi)
    func placePiece() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    // Hatalı hamle veya sığmayan parça (Hızlı 'bızz-bızz' uyarısı)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Özel Durumlar (Game Events)

    // Bölüm geçince (Uzun ve yumuşak bir zafer titreşimi)
    func levelComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    // Joker kullanınca (Mekanik, keskin ve güçlü bir his - Parça üretildi!)
    func useJoker() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: 1.0)
    }

    // Undo veya Hint gibi butonlara basınca (Standart sistem tıklaması)
    func buttonTap() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // OYUN BİTTİ (Ağır ve dramatik bir darbe veya uyarı)
    func gameOver() {
        // İki seçenek var, oyunun tonuna göre seçebilirsin:

        // Seçenek 1: Uyarı titreşimi (Dikkat çekici)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)

        // Seçenek 2 (Alternatif): Çok ağır bir darbe (Daha dramatik)
        // let impact = UIImpactFeedbackGenerator(style: .heavy)
        // impact.impactOccurred()
    }
}
