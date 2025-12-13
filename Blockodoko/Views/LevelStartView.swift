import SwiftUI

import SwiftUI

struct LevelStartView: View {
    let levelNumber: Int
    // Ekstra bilgiler ekleyelim ki ekran dolu gözüksün
    let gridSize: Int       // Örn: 8
    let targetPieces: Int   // Örn: 25
    let difficultyName: String // Örn: "Med-Hard"
    let onStart: () -> Void

    // Animasyon state'i
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // 1. Arka Plan: Buzlu Cam Efekti (iOS 15+)
            // Oyuncuyu tamamen koparmaz, alttaki grid flu görünür
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.4)) // Biraz daha karanlık

            // 2. Ana Kart
            VStack(spacing: 25) {

                // Başlık Grubu
                VStack(spacing: 5) {
                    Text(difficultyName.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundColor(difficultyColor)
                        .cornerRadius(8)

                    Text("LEVEL \(levelNumber)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .gray],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0)
                }

                // İstatistikler / Hedefler (Bilgi Kartları)
                HStack(spacing: 15) {
                    InfoBadge(icon: "square.grid.2x2.fill", title: "Grid", value: "\(gridSize)x\(gridSize)")
                    InfoBadge(icon: "cube.fill", title: "Target", value: "\(targetPieces)")
                }

                // Play Butonu
                Button(action: {
                    // Haptic Feedback (Titreşim)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onStart()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("START GAME")
                    }
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .frame(width: 220, height: 65)
                    .background(
                        LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.orange.opacity(0.6), radius: 15, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                }
                .padding(.top, 10)
            }
            .padding(40)
            .scaleEffect(isAnimating ? 1 : 0.8) // Giriş animasyonu
            .opacity(isAnimating ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
        }
    }

    // Zorluğa göre renk değiştiren computed property
    var difficultyColor: Color {
        switch gridSize {
        case 6: return .green
        case 7, 8: return .blue
        case 9: return .purple
        case 10...12: return .red
        default: return .yellow
        }
    }
}

// Yardımcı View: Küçük bilgi kutucukları
struct InfoBadge: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(width: 100, height: 90)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Önizleme
#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        LevelStartView(
            levelNumber: 2,
            gridSize: 8,
            targetPieces: 12,
            difficultyName: "Intermediate",
            onStart: {}
        )
        .environmentObject(GameViewModel())
    }
}
