import SwiftUI

struct TrayView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var draggedPiece: BlockPiece?
    @Binding var dragLocation: CGPoint
    @Binding var dragOffset: CGSize
    @Binding var trayFrame: CGRect

    // Sabit hücre boyutu (Hesaplamalarda kullanmak için)
    private let pieceCellSize: CGFloat = 15

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) { // ScrollIndicator kapalı daha şık
                HStack(spacing: 20) {
                    ForEach(viewModel.tray) { piece in
                        // Performans için ZStack yerine overlay/background veya doğrudan View
                        PieceView(piece: piece, cellSize: pieceCellSize)
                            .scaleEffect(0.8)
                        // Eğer bu parça sürükleniyorsa yerinde sadece boşluk kalsın (Opacity 0)
                            .opacity(draggedPiece?.id == piece.id ? 0 : 1)

                        // Parça boyutunu GeometryReader OLMADAN hesapla
                            .frame(
                                width: CGFloat(piece.matrix[0].count) * pieceCellSize + 10,
                                height: CGFloat(piece.matrix.count) * pieceCellSize + 10
                            )

                        // Gesture optimizasyonu: HighPriority (Scroll'u engellemek için)
                        // MinimumDistance 0 (Anında tepki için)
                            .highPriorityGesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                    .onChanged { value in
                                        // Sürükleme başladığında (ilk tetiklenme)
                                        if draggedPiece == nil {
                                            HapticManager.shared.liftPiece()
                                            draggedPiece = piece

                                            // Offset ayarı: Parça parmağın biraz üstünde görünsün
                                            dragOffset = CGSize(width: 0, height: -60)
                                        }

                                        // Konumu güncelle
                                        dragLocation = value.location
                                    }
                                    .onEnded { _ in
                                        // Bırakma işlemi MainGameView'da yönetiliyor
                                        // Burası boş kalabilir veya temizlik yapılabilir
                                    }
                            )
                    }
                }
                .padding()
                // ScrollView içeriği en az ekran genişliği kadar olsun
                .frame(minWidth: geo.size.width, alignment: .leading)
            }
            // Sadece TEPSİ boyutunu hesapla (Parçalarınkini değil)
            .onAppear {
                self.trayFrame = geo.frame(in: .global)
            }
            .onChange(of: geo.frame(in: .global)) { newFrame in
                self.trayFrame = newFrame
            }
        }
        .frame(height: 110)
        .background(Color.themeTray)
        .cornerRadius(16)
    }
}
