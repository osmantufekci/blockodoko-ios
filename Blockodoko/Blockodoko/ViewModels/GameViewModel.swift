import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var board: [[Cell]] = []
    @Published var tray: [BlockPiece] = []
    @Published var displayLevelSeed: String = ""
    @Published var difficulty: Difficulty = .medHard
    @Published var coins: Int = 1000
    @Published var gameStatus: String = "Ready"
    @Published var previewCells: Set<String> = [] // Coordinates "x,y"


    // Internal State
    private var rng: SeededRNG?
    private var currentGridSize: Int = 8

    // Constants
    private let colors = ["c-0", "c-1", "c-2", "c-3", "c-4", "c-5"]

    init() {
        self.coins = UserDefaults.standard.integer(forKey: "gm_coins")
        if self.coins == 0 { self.coins = 1000 } // Default if not set or 0
        startLevel(difficulty: .medHard)
    }

    // MARK: - Level Generation

    func startLevel(difficulty: Difficulty, specificSeed: String? = nil) {
        self.difficulty = difficulty
        self.currentGridSize = difficulty.gridSize

        // Generate Seed
        let seed = specificSeed ?? generateRandomSeed()
        self.displayLevelSeed = seed
        self.rng = SeededRNG(seedString: seed)

        generateLevel(difficulty: difficulty)
    }

    private func generateRandomSeed() -> String {
        let timestamp = String(Int(Date().timeIntervalSince1970), radix: 36)
        let randomPart = String(Int.random(in: 10000...99999), radix: 36)
        return (timestamp + randomPart).uppercased()
    }

    private func generateLevel(difficulty: Difficulty) {
        guard let rng = self.rng else { return }

        // 1. Init Empty Board
        var newBoard = (0..<currentGridSize).map { y in
            (0..<currentGridSize).map { x in Cell(x: x, y: y) }
        }

        // 2. Prefill Obstacles
        // JS: Math.floor(remaining * (currentRNG.next() * (lvl.prefillMax - lvl.prefillMin) + lvl.prefillMin));
        let totalCells = Double(currentGridSize * currentGridSize)
        let rates = difficulty.prefillRange
        let prefillFactor = rng.next() * (rates.upperBound - rates.lowerBound) + rates.lowerBound
        var prefillTarget = Int(totalCells * prefillFactor)

        var remainingEmpty = Int(totalCells)

        while prefillTarget > 0 && remainingEmpty > 0 {
            let hx = Int(rng.next() * Double(currentGridSize))
            let hy = Int(rng.next() * Double(currentGridSize))

            if !newBoard[hy][hx].isFilled {
                newBoard[hy][hx].isFilled = true
                newBoard[hy][hx].isLocked = true
                newBoard[hy][hx].color = "prefill_gray" // Special color for obstacles
                remainingEmpty -= 1
                prefillTarget -= 1
            }
        }

        self.board = newBoard

        // 3. Generate Tray Pieces (Virtual Grid Simulation)
        var virtualGrid = newBoard.map { row in row.map { $0.isFilled ? 0 : 1 } } // 1 is available space in JS logic
        // NOTE: In JS logic:
        // boardState[hy][hx] = 1 (filled) -> virtualGrid[hy][hx] = 0 (unavailable)

        var piecesForTray: [BlockPiece] = []
        var failSafe = 0

        // JS: while(remaining > 0 && failSafe < 3000)
        // We reuse `remainingEmpty` which tracks empty spots on board (virtualGrid has 1s)

        while remainingEmpty > 0 && failSafe < 3000 {
            failSafe += 1
            let sx = Int(rng.next() * Double(currentGridSize))
            let sy = Int(rng.next() * Double(currentGridSize))

            if virtualGrid[sy][sx] == 0 { continue }

            // shapeType logic
            let shapeType = (currentGridSize >= 9 && rng.next() > 0.4) ? "blob" : "rect"
            let maxPieceSize = min(6, (currentGridSize / 2) + 1)
            let size = min(remainingEmpty, Int(rng.next() * Double(maxPieceSize)) + 2)

            let shapeData: BlockPiece?

            if shapeType == "rect" {
                shapeData = growRectangle(vGrid: &virtualGrid, sx: sx, sy: sy, targetSize: size)
            } else {
                shapeData = growBlob(vGrid: &virtualGrid, sx: sx, sy: sy, targetSize: size)
            }

            if let shape = shapeData, !shape.matrix.isEmpty {
                piecesForTray.append(shape)

                // Deduct from remaining
                var count = 0
                for row in shape.matrix {
                    for val in row {
                        if val == 1 { count += 1 }
                    }
                }
                remainingEmpty -= count
            }
        }

        self.tray = piecesForTray
    }

    // MARK: - Shape Growing Algorithms

    private func growRectangle(vGrid: inout [[Int]], sx: Int, sy: Int, targetSize: Int) -> BlockPiece? {
        guard let rng = self.rng else { return nil }
        var attempts = 0

        while attempts < 10 {
            attempts += 1
            let w = Int(rng.next() * Double(targetSize)) + 1
            let h = Int(ceil(Double(targetSize) / Double(w)))

            if (w * h) > (targetSize + 2) { continue }
            if (sx + w > currentGridSize) || (sy + h > currentGridSize) { continue }

            var fits = true
            for y in 0..<h {
                for x in 0..<w {
                    if vGrid[sy + y][sx + x] == 0 {
                        fits = false
                        break
                    }
                }
                if !fits { break }
            }

            if fits {
                // Mark used in virtual grid
                for y in 0..<h {
                    for x in 0..<w {
                        vGrid[sy + y][sx + x] = 0
                    }
                }
                let matrix = Array(repeating: Array(repeating: 1, count: w), count: h)
                return BlockPiece(matrix: matrix, color: getRandomColor(), targetX: sx, targetY: sy)
            }
        }

        // Fallback to blob
        return growBlob(vGrid: &vGrid, sx: sx, sy: sy, targetSize: targetSize)
    }

    private struct Point: Hashable { let x: Int; let y: Int }

    private func growBlob(vGrid: inout [[Int]], sx: Int, sy: Int, targetSize: Int) -> BlockPiece? {
        guard let rng = self.rng else { return nil }

        var region: [Point] = []
        region.append(Point(x: sx, y: sy))
        vGrid[sy][sx] = 0

        var i = 0
        while region.count < targetSize && i < region.count {
            let current = region[i]
            // dirs shuffle
            var dirs = [[0,1], [0,-1], [1,0], [-1,0]]
            // Minimal shuffle simulation using rng
            dirs.sort { _, _ in rng.next() > 0.5 }

            for d in dirs {
                let nx = current.x + d[1]
                let ny = current.y + d[0]

                if nx >= 0 && nx < currentGridSize && ny >= 0 && ny < currentGridSize && vGrid[ny][nx] == 1 {
                    vGrid[ny][nx] = 0
                    region.append(Point(x: nx, y: ny))
                }
            }
            i += 1
        }

        // Convert region to matrix
        let minX = region.map { $0.x }.min() ?? 0
        let minY = region.map { $0.y }.min() ?? 0
        let maxX = region.map { $0.x }.max() ?? 0
        let maxY = region.map { $0.y }.max() ?? 0

        let width = maxX - minX + 1
        let height = maxY - minY + 1

        var matrix = Array(repeating: Array(repeating: 0, count: width), count: height)
        for p in region {
            matrix[p.y - minY][p.x - minX] = 1
        }

        return BlockPiece(matrix: matrix, color: getRandomColor(), targetX: minX, targetY: minY)
    }



    // MARK: - Game Interaction

    func canPlace(piece: BlockPiece, at x: Int, y: Int) -> Bool {
        let matrix = piece.matrix
        for r in 0..<matrix.count {
            for c in 0..<matrix[r].count {
                if matrix[r][c] == 1 {
                    let tx = x + c
                    let ty = y + r

                    // Check Bounds
                    if tx < 0 || tx >= currentGridSize || ty < 0 || ty >= currentGridSize {
                        return false
                    }

                    // Check Collision
                    if board[ty][tx].isFilled {
                        return false
                    }
                }
            }
        }
        return true
    }

    func place(piece: BlockPiece, at x: Int, y: Int) {
        // 1. Save History for Undo
        // (Simplified: In a real app we'd deep copy board)
        // For MVP we might skip complex Undo or implement it later

        // 2. Place on Board
        let matrix = piece.matrix
        for r in 0..<matrix.count {
            for c in 0..<matrix[r].count {
                if matrix[r][c] == 1 {
                    let tx = x + c
                    let ty = y + r
                    board[ty][tx].isFilled = true
                    board[ty][tx].color = piece.color
                }
            }
        }

        // 3. Remove from Tray
        if let idx = tray.firstIndex(where: { $0.id == piece.id }) {
            tray.remove(at: idx)
        }

        // 4. Check Win
        checkWinCondition()

        // Reset Preview
        previewCells.removeAll()
    }

    private func checkWinCondition() {
        // Goal: Fill all cells?
        // Logic from JS: if(boardState.every(r=>r.every(v=>v!==0)))

        let allFilled = board.flatMap { $0 }.allSatisfy { $0.isFilled }
        if allFilled {
            gameStatus = "Victory!"
            let reward = difficulty.levelClearReward
            addCoins(amount: reward)
        }
    }

    // MARK: - Economy

    func addCoins(amount: Int) {
        coins += amount
        UserDefaults.standard.set(coins, forKey: "gm_coins")
    }

    func spendCoins(amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            UserDefaults.standard.set(coins, forKey: "gm_coins")
            return true
        }
        return false
    }

    // MARK: - Powerups

    func useHint() {
        let cost = 100
        guard !tray.isEmpty else { return }

        // Check if user has free hints or needs to pay (simplified to pay only for now)
        if spendCoins(amount: cost) {
            // Find a piece that fits
            // JS: calls findBestPlacement logic
            // In Swift we would scan the board for valid placements using canPlace
            for piece in tray {
                if let placement = findPlacement(for: piece) {
                    // Auto place it
                    place(piece: piece, at: placement.x, y: placement.y)
                    return
                }
            }
        }
    }

    private func findPlacement(for piece: BlockPiece) -> (x: Int, y: Int)? {
        // Brute force scan
        for y in 0..<currentGridSize {
            for x in 0..<currentGridSize {
                if canPlace(piece: piece, at: x, y: y) {
                    // Check if this placement matches the target (if we wanted to be strict)
                    // But any valid placement is OK for a hint usually
                    // The JS code actually checks `canPlacePerfectly` which checks if `s.targetX` matches.
                    // Since we stored targetX/Y in BlockPiece, we can use that!
                    if let tx = piece.targetX, let ty = piece.targetY {
                        if x == tx && y == ty {
                            return (x, y)
                        }
                    }
                    // Fallback if we lost target info or it's flexible
                    return (x, y)
                }
            }
        }
        return nil
    }

    func createJokerPiece(matrix: [[Int]]) -> Bool {
        // Cost: 200
        if spendCoins(amount: 200) {
            // Trim matrix logic (cropMat in JS)
            // Find bounds
            var minX=5, maxX = -1, minY=5, maxY = -1
            for r in 0..<5 {
                for c in 0..<5 {
                    if matrix[r][c] == 1 {
                        if c < minX { minX = c }
                        if c > maxX { maxX = c }
                        if r < minY { minY = r }
                        if r > maxY { maxY = r }
                    }
                }
            }

            let h = maxY - minY + 1
            let w = maxX - minX + 1
            var newItem = Array(repeating: Array(repeating: 0, count: w), count: h)

            for r in 0..<h {
                for c in 0..<w {
                    newItem[r][c] = matrix[minY+r][minX+c]
                }
            }

            let piece = BlockPiece(matrix: newItem, color: "c-3", targetX: nil, targetY: nil)
            tray.append(piece)
            return true
        }
        return false
    }

    func findBestPlacement(nearGridX centerGx: Int, nearGridY centerGy: Int, piece: BlockPiece) -> (x: Int, y: Int)? {
        let offsetX = piece.matrix[0].count / 2
        let offsetY = piece.matrix.count / 2

        var bestX = -1
        var bestY = -1
        var minD = Double.infinity

        // Exact port of JS Logic:
        // const centerGx = Math.round((relX / cellPixelSize) - 0.5);
        // centerGx is passed in.
        // Loop dy -1 to 1, dx -1 to 1

        for dy in -1...1 {
            for dx in -1...1 {
                let csx = (centerGx + dx) - offsetX
                let csy = (centerGy + dy) - offsetY

                if canPlace(piece: piece, at: csx, y: csy) {
                    // const dist = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
                    let dist = Double(dx*dx + dy*dy) // Comparison works without sqrt
                    if dist < minD {
                        minD = dist
                        bestX = csx
                        bestY = csy
                    }
                }
            }
        }

        if bestX != -1 {
            return (bestX, bestY)
        }
        return nil
    }

    func updatePreview(nearGridX gX: Int, nearGridY gY: Int, piece: BlockPiece?) {
        guard let piece = piece else {
            previewCells.removeAll()
            return
        }

        if let best = findBestPlacement(nearGridX: gX, nearGridY: gY, piece: piece) {
            var newPreview: Set<String> = []
            let matrix = piece.matrix
            for r in 0..<matrix.count {
                for c in 0..<matrix[r].count {
                    if matrix[r][c] == 1 {
                        let tx = best.x + c
                        let ty = best.y + r
                        newPreview.insert("\(tx),\(ty)")
                    }
                }
            }
            previewCells = newPreview
        } else {
            previewCells.removeAll()
        }
    }

    func getRandomColor() -> String {

        guard let rng = self.rng else { return "c-0" }
        if difficulty == .god && rng.next() > 0.8 {
            return "c-god"
        }
        let idx = Int(rng.next() * Double(colors.count))
        return colors[min(idx, colors.count - 1)]
    }
}

