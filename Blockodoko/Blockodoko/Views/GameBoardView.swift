import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var boardFrame: CGRect
    var onLiftPiece: ((BlockPiece, CGPoint) -> Void)?
    var onDragChanged: ((CGPoint) -> Void)?
    var onDragEnded: ((CGPoint) -> Void)?

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(viewModel.board.count - 1)
            let cellSize = (width - totalSpacing) / CGFloat(viewModel.board.count)

            ZStack {
                VStack(spacing: spacing) {
                    ForEach(viewModel.board.indices, id: \.self) { y in
                        HStack(spacing: spacing) {
                            ForEach(viewModel.board[y].indices, id: \.self) { x in
                                let cell = viewModel.board[y][x]
                                let isPreview = viewModel.previewCells.contains("\(x),\(y)")
                                CellView(cell: cell, size: cellSize, isPreview: isPreview)
                            }
                        }
                    }
                }

                Color.white.opacity(0.001)
                // DEĞİŞİKLİK BURADA: .gesture yerine .highPriorityGesture kullanıyoruz
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { value in
                                // ... (Kodların aynısı) ...
                                let globalLocation = value.location
                                let frame = geo.frame(in: .global)
                                let relX = value.location.x - frame.minX
                                let relY = value.location.y - frame.minY
                                let col = Int(relX / (cellSize + spacing))
                                let row = Int(relY / (cellSize + spacing))

                                if col >= 0 && col < viewModel.board.count &&
                                    row >= 0 && row < viewModel.board.count {

                                    if let liftedPiece = viewModel.liftPiece(at: col, y: row) {
                                        HapticManager.shared.liftPiece()
                                        onLiftPiece?(liftedPiece, globalLocation)
                                    }
                                }
                                onDragChanged?(globalLocation)
                            }
                            .onEnded { value in
                                // HighPriority olduğu için artık tepsi üzerinde de çalışır
                                onDragEnded?(value.location)
                            }
                    )
            }
            .onAppear {
                DispatchQueue.main.async {
                    self.boardFrame = geo.frame(in: .global)
                }
            }
            .onChange(of: geo.frame(in: .global)) { newFrame in
                self.boardFrame = newFrame
            }
        }
    }
}

#Preview {
    GameBoardView(viewModel: .init(), boardFrame: .constant(CGRect(x: 12, y: 21, width: 60, height: 50)))
}
