import SwiftUI

struct JokerModalView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var isPresented: Bool
    
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 5)
    @State var cost = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("Joker Piece")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Draw your shape")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(spacing: 2) {
                    ForEach(0..<5) { r in
                        HStack(spacing: 2) {
                            ForEach(0..<5) { c in
                                Rectangle()
                                    .fill(grid[r][c] == 1 ? Color(hex: "E040FB") : Color(hex: "333"))
                                    .frame(width: 40, height: 40)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .onTapGesture {
                                        if grid[r][c] == 1 {
                                            grid[r][c] = 0
                                            cost -= 100
                                        } else {
                                            grid[r][c] = 1
                                            cost += 100
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(hex: "222"))
                .cornerRadius(8)
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)

                    let title = cost == 0 ? "Create" : "Create (\(cost)💰)"
                    Button(title) {
                        createJoker()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "E040FB"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(30)
            .background(Color(hex: "1e1e1e"))
            .cornerRadius(16)
            .shadow(radius: 20)
        }
    }
    
    private func createJoker() {
        let hasBlock = grid.flatMap { $0 }.contains(1)
        guard hasBlock else { return }
        
        if !isConnected(grid) { return }

        if viewModel.createJokerPiece(matrix: grid) {
            isPresented = false
        }
    }
    
    private func isConnected(_ m: [[Int]]) -> Bool {
        var pts: [Point] = []
        for r in 0..<5 {
            for c in 0..<5 {
                if m[r][c] == 1 { pts.append(Point(x: c, y: r)) }
            }
        }
        if pts.isEmpty { return false }
        
        var q = [pts[0]]
        var visited = Set<Point>()
        visited.insert(pts[0])
        var count = 0
        
        while !q.isEmpty {
            let curr = q.removeFirst()
            count += 1
            
            let dirs = [(0,1), (0,-1), (1,0), (-1,0)]
            for d in dirs {
                let nx = curr.x + d.0
                let ny = curr.y + d.1
                if nx >= 0 && nx < 5 && ny >= 0 && ny < 5 && m[ny][nx] == 1 {
                    let nextP = Point(x: nx, y: ny)
                    if !visited.contains(nextP) {
                        visited.insert(nextP)
                        q.append(nextP)
                    }
                }
            }
        }
        
        return count == pts.count
    }
    
    private struct Point: Hashable { let x: Int, y: Int }
}

#Preview {
    JokerModalView(
        viewModel: .init(),
        isPresented: .constant(true)
    )
}
