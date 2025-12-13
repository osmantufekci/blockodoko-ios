import SwiftUI

struct PieceView: View {
    let piece: BlockPiece
    let cellSize: CGFloat

    var body: some View {
        // spacing: 1.5 -> Parçanın içindeki bloklar arası boşluk (bunu değiştirebilirsin)
        VStack(spacing: 1.5) {
            ForEach(0..<piece.matrix.count, id: \.self) { r in
                HStack(spacing: 1.5) {
                    ForEach(0..<piece.matrix[r].count, id: \.self) { c in
                        if piece.matrix[r][c] == 1 {
                            // Dolu Blok
                            BlockUnitView(
                                color: piece.color,
                                size: cellSize,
                                isGhost: false
                            )
                        } else {
                            // Boş Blok (Görünmez ama yer kaplar)
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .drawingGroup()
    }
}

#Preview("Piece View") {
    PieceView(
        piece: .init(
            matrix: [[1], [0,1,0], [0,1,1], ],
            color: "c-0"
        ),
        cellSize: 256
    )
}

#Preview("Whole game") {
    @Previewable @StateObject var navigationManager: NavigationManager = .shared
    NavigationStack(path: $navigationManager.path) {
        MainGameView()
            .environmentObject(GameViewModel())
            .environmentObject(AdsManager.shared)
            .preferredColorScheme(.dark)
            .navigationDestination(for: NavigationView<AnyView>.self) { destination in
                destination
            }
    }
    .environmentObject(navigationManager)
}
