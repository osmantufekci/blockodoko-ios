import SwiftUI

struct PieceView: View {
    let piece: BlockPiece
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 1.5) {
            ForEach(0..<piece.matrix.count, id: \.self) { r in
                HStack(spacing: 1.5) {
                    ForEach(0..<piece.matrix[r].count, id: \.self) { c in
                        Group {
                            if piece.matrix[r][c] == 1 {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.from(string: piece.color))
                            } else {
                                Color.clear
                            }
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding(5)
        
    }
}
