import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    // Parçayı eline alınca (Hafif)
    func liftPiece() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Parçayı yerine oturtunca (Orta)
    func placePiece() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Hatalı hamle veya sığmayan parça (Hata)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // Bölüm geçince (Başarı)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}