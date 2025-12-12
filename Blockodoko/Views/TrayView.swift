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
                            .opacity(draggedPiece?.id == piece.id ? 0 : 1)
                            .frame(
                                width: CGFloat(piece.matrix[0].count) * pieceCellSize + 10,
                                height: CGFloat(piece.matrix.count) * pieceCellSize + 10
                            )
                            .highPriorityGesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                    .onChanged { value in
                                        // Sürükleme başladığında (ilk tetiklenme)
                                        if draggedPiece == nil {
                                            HapticManager.shared.liftPiece()
                                            draggedPiece = piece
                                            dragOffset = CGSize(width: 0, height: -60)
                                        }

                                        dragLocation = value.location
                                    }
                                    .onEnded { _ in
                                        draggedPiece = nil
                                        dragOffset = .zero
                                        dragLocation = .zero
                                    }
                            )
                    }
                }
                .padding()
                .frame(minWidth: geo.size.width, alignment: .leading)
            }
            .onAppear {
                self.trayFrame = geo.frame(in: .global)
            }
            .onChange(of: geo.frame(in: .global)) { newFrame, _ in
                self.trayFrame = newFrame
            }
        }
        .frame(height: 110)
        .background(Color.themeTray)
        .cornerRadius(16)
    }
}
