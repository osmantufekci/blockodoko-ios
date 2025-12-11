import SwiftUI

struct CellView: View {
    let cell: Cell
    let size: CGFloat
    var isPreview: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(fillColor)
                .frame(width: size, height: size)
            
            if cell.isFilled, cell.isLocked {
                DiagonalStripes()
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    .clipShape(Rectangle())
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    var fillColor: Color {
        if isPreview {
            return Color.white.opacity(0.3)
        }
        if cell.isFilled {
            if let c = cell.color {
                return Color.from(string: c)
            }
            return .gray
        } else {
            return Color(hex: "2a2a2a")
        }
    }
}

#Preview {
    var cell = Cell(x: 4, y: 8, isFilled: true, isLocked: true)
    return CellView(cell: cell, size: .init(64))
}
