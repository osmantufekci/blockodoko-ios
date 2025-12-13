import SwiftUI

struct CellView: View {
    let cell: Cell
    let size: CGFloat
    let isPreview: Bool
    let texture: Texture

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.themeBoard)
                .frame(width: size, height: size)

            if cell.isFilled {
                BlockUnitView(
                    color: cell.color ?? "c-0",
                    size: size,
                    isGhost: false
                )
                .transition(.scale.combined(with: .opacity))

            } else if isPreview {
                BlockUnitView(
                    color: "gray",
                    size: size,
                    isGhost: true
                )
            }
        }
    }
}

#Preview {
    var cell = Cell(x: 4, y: 8, isFilled: true, isLocked: true)
    CellView(cell: cell, size: 256, isPreview: false, texture: .radial)
}
