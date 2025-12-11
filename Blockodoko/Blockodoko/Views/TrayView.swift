import SwiftUI

struct TrayView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var draggedPiece: BlockPiece?
    @Binding var dragLocation: CGPoint
    @Binding var dragOffset: CGSize

    @Binding var trayFrame: CGRect

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    ForEach(viewModel.tray) { piece in
                        GeometryReader { geo in
                            PieceView(piece: piece, cellSize: 15)
                                .scaleEffect(0.8)
                                .opacity(draggedPiece?.id == piece.id ? 0 : 1)
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { value in
                                            if draggedPiece == nil {
                                                draggedPiece = piece
                                                HapticManager.shared.liftPiece()
                                            }
                                            dragLocation = value.location
                                            dragOffset = value.translation
                                        }
                                        .onEnded { value in
                                            withAnimation {
                                                // Let checkWin/Drop happen in onChange(of: draggedPiece) or similar
                                                // or let MainGameView handle the drop logic based on state change
                                                draggedPiece = nil // Resets for now, MainGameView will intercept "nil" transition
                                            }
                                        }
                                )
                        }
                        .frame(width: CGFloat(piece.matrix[0].count * 15 + 10), height: CGFloat(piece.matrix.count * 15 + 10))
                    }
                }
                .padding()
                .frame(minWidth: geo.size.width)
            }
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
