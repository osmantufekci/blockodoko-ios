import SwiftUI

struct DiagonalStripes: Shape {
    var lineWidth: CGFloat = 3
    var spacing: CGFloat = 6 // Çizgiler arası boşluk

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Çizgilerin taşmaması için clipping yapmaya gerek yok, Shape zaten frame içinde kalır.
        // Çapraz uzunluk (Pisagor: a^2 + b^2 = c^2)
        // Maksimum döngü sayısı için diyagonal uzunluğu baz alıyoruz.
        let diagonal = sqrt(pow(rect.width, 2) + pow(rect.height, 2))
        let count = Int(diagonal / (lineWidth + spacing)) * 2 // Bolca çizgi olsun
        
        for i in -count...count {
            // Çizginin başlangıç X noktası
            let x = CGFloat(i) * (lineWidth + spacing)
            
            // Başlangıç (Alt)
            path.move(to: CGPoint(x: x, y: rect.height))
            // Bitiş (Üst - Sağa yatık /)
            path.addLine(to: CGPoint(x: x + rect.height, y: 0))
            
            // Eğer sola yatık istersen (\):
            // path.move(to: CGPoint(x: x, y: 0))
            // path.addLine(to: CGPoint(x: x + rect.height, y: rect.height))
        }
        
        return path
    }
}