import SwiftUI

struct TrayView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var draggedPiece: BlockPiece?
    @Binding var dragLocation: CGPoint
    @Binding var dragOffset: CGSize
    @Binding var trayFrame: CGRect

    // Sabit hücre boyutu (Hesaplamalarda kullanmak için)
    private let pieceCellSize: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.tray) { piece in
                        PieceView(
                            piece: piece,
                            cellSize: pieceCellSize
                        )
                        .opacity(draggedPiece == piece ? 0.1 : 1)
                        .frame(
                            width: CGFloat(piece.matrix[0].count) * pieceCellSize + 10,
                            height: CGFloat(piece.matrix.count) * pieceCellSize + 10
                        )
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onChanged { value in
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
        .frame(minHeight: 110, maxHeight: 130)
        .background(Color.themeTray)
        .cornerRadius(16)
    }
}


#Preview {
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
