import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var boardFrame: CGRect
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(viewModel.board.count - 1)
            let cellSize = (width - totalSpacing) / CGFloat(viewModel.board.count)
            
            VStack(spacing: spacing) {
                ForEach(viewModel.board.indices, id: \.self) { y in
                    HStack(spacing: spacing) {
                        ForEach(viewModel.board[y].indices, id: \.self) { x in
                            let isPreview = viewModel.previewCells.contains("\(x),\(y)")
                            CellView(cell: viewModel.board[y][x], size: cellSize, isPreview: isPreview)
                                .gesture(
                                    TapGesture().onEnded {
                                        // Handle magnet/remove mode if implemented
                                    }
                                )
                        }
                    }
                }
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
        .aspectRatio(1, contentMode: .fit)
        .padding(5)
        .background(Color.themeBoard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
    }
}

#Preview {
    GameBoardView(viewModel: .init(), boardFrame: .constant(CGRect(x: 12, y: 21, width: 60, height: 50)))
}
