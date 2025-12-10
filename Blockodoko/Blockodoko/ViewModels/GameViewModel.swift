//
//  GameViewModel.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 10.12.2025.
//
import SwiftUI
import Combine

// MARK: - Game View Model
class GameViewModel: ObservableObject, GameContext {
    // --- PUBLISHED STATE ---
    @Published var board: [[Cell]] = []
    @Published var tray: [BlockPiece] = [] // Artık TÜM parçalar burada duracak
    @Published var currentLevel: Int = 1
    @Published var difficulty: Difficulty = .medHard

    // Progress
    @Published var totalPiecesTarget: Int = 0
    @Published var piecesPlacedCount: Int = 0

    // UI State
    @Published var showLevelStartModal: Bool = true
    @Published var showGameOverModal: Bool = false
    @Published var gameStatus: String = "Ready"
    @Published var coins: Int = 1000
    @Published var previewCells: Set<String> = []
    @Published var showJokerModal = false

    // Internal State
    private var rng: SeededRNG?
    var currentGridSize: Int = 8
    private var moveHistory: [GameStateSnapshot] = []
    private let colors = ["c-0", "c-1", "c-2", "c-3", "c-4", "c-5"]

    init() {
        UserDefaults.standard.removeObject(forKey: "userCurrentLevel")
        self.currentLevel = UserDefaults.standard.integer(forKey: "userCurrentLevel")
        if self.currentLevel == 0 { self.currentLevel = 1 }

        self.coins = UserDefaults.standard.integer(forKey: "gm_coins")
        if self.coins <= 100 { self.coins = 1000 }
        print("userdefaults level:", UserDefaults.standard.integer(forKey: "userCurrentLevel"))
    }

    // MARK: - Level Loading Logic

    func loadLevel(_ levelNumber: Int) {
        guard let data = LevelLibrary.getLevel(number: levelNumber) else {
            print("Level not found, restarting logic or showing end game.")
            return
        }

        self.currentLevel = levelNumber
        self.difficulty = data.difficulty
        self.currentGridSize = data.difficulty.gridSize
        self.piecesPlacedCount = 0
        self.gameStatus = "Playing"

        self.rng = SeededRNG(seedString: data.seed)

        generateLevelInternal(difficulty: data.difficulty)
    }

    // Olası bir hamle kaldı mı diye kontrol eder
    func checkGameOver() {
        // Eğer tahta dolduysa zaten place fonksiyonunda yakalanır ama yine de bakalım
        if checkWinCondition() { return }

        // Tepsi boşsa ve tahta dolmadıysa -> YANLIŞ YERLEŞTİRME (Stuck)
        // Bu durumda Undo yapılması veya Restart edilmesi gerekir.
        if tray.isEmpty {
            // Tahta dolmadı ama parça bitti. Demek ki Joker kullanmıştık veya yanlış yaptık.
            // Ama paran varsa hala Joker ile 1x1 üretebilirsin.
            if coins >= jokerManager.getJoker(id: .piece)?.cost ?? 0 {
                gameStatus = "Use Joker!"
                return
            }

            print("Game Over: Board not full and no pieces left!")
            triggerGameOver()
            return
        }

        // --- NORMAL SIKIŞMA KONTROLÜ ---
        // Mevcut parçalardan EN AZ BİRİ bir yere sığıyor mu?
        for piece in tray {
            for y in 0..<currentGridSize {
                for x in 0..<currentGridSize {
                    if canPlace(piece: piece, at: x, y: y) {
                        return // Hamle var, devam.
                    }
                }
            }
        }

        // Parça sığmıyor... Peki Joker parası var mı?
        if coins >= 200 {
            gameStatus = "Use Joker!"
            return
        }

        print("Game Over: No moves left!")
        triggerGameOver()
    }

    func triggerGameOver() {
        print("Game Over: No moves left!")
        gameStatus = "Game Over"
        withAnimation(Animation.easeIn.delay(0.25)) {
            showGameOverModal = true
            HapticManager.shared.gameOver()
        }
        // Burada bir "Yandın" modalı açabilirsin
        // showGameOverModal = true
    }

    func undoMove() {
        // 1. Geçmiş boşsa işlem yapma
        guard let lastState = moveHistory.popLast() else { return }

        // 2. Maliyeti düş (Eğer Game Over ekranından çağrılıyorsa zaten orada kontrol edilebilir
        // ama butondan çağrılıyorsa buradan düşmek gerekir.)
        // Not: Eğer Game Over ekranında "Bedava" veya "Reklamla" vereceksen buradaki if'i kaldırabilirsin.
        let cost = 50
        if spendCoins(amount: cost) {
            applySnapshot(lastState)
        } else {
            // Para yetmediyse geçmişi geri yerine koy (Pop etmiştik)
            moveHistory.append(lastState)

            // Titreşim (Hata)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    func checkWinCondition() -> Bool {
        for row in board {
            for cell in row {
                if !cell.isFilled {
                    return false
                }
            }
        }
        return true
    }

    private func applySnapshot(_ state: GameStateSnapshot) {
        self.board = state.board
        self.tray = state.tray
        self.piecesPlacedCount = state.piecesPlacedCount
        self.gameStatus = "Playing" // Game Over ise oyunu tekrar aktif et

        // Başarılı titreşim
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func saveState() {
        let snapshot = GameStateSnapshot(
            board: self.board,
            tray: self.tray,
            piecesPlacedCount: self.piecesPlacedCount
        )
        moveHistory.append(snapshot)
    }

    private func generateLevelInternal(difficulty: Difficulty) {
        guard let rng = self.rng else { return }

        // 1. Board Sıfırla
        var newBoard = (0..<currentGridSize).map { y in
            (0..<currentGridSize).map { x in Cell(x: x, y: y) }
        }

        // 2. Engel (Prefill) Yerleştirme
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
                newBoard[hy][hx].color = "prefill_gray"
                remainingEmpty -= 1
                prefillTarget -= 1
            }
        }
        self.board = newBoard

        // 3. Parça Üretimi (Virtual Grid Solution)
        var virtualGrid = newBoard.map { row in row.map { $0.isFilled ? 0 : 1 } }
        var generatedPieces: [BlockPiece] = []
        var failSafe = 0

        // Kalan boşlukları dolduracak kadar parça üret
        while remainingEmpty > 0 && failSafe < 3000 {
            failSafe += 1
            let sx = Int(rng.next() * Double(currentGridSize))
            let sy = Int(rng.next() * Double(currentGridSize))

            if virtualGrid[sy][sx] == 0 { continue }

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
                generatedPieces.append(shape)
                let count = shape.matrix.flatMap { $0 }.filter { $0 == 1 }.count
                remainingEmpty -= count
            }
        }

        // 4. Parçaları Tepsiye Ata
        // DÜZELTME: Queue yok, refill yok. Hepsi direkt tepsiye.
        self.tray = generatedPieces
        self.totalPiecesTarget = generatedPieces.count
    }

    // refillTray() METODU SİLİNDİ (Artık ihtiyaç yok)

    // MARK: - Game Interaction

    func canPlace(piece: BlockPiece, at x: Int, y: Int) -> Bool {
        let matrix = piece.matrix
        for r in 0..<matrix.count {
            for c in 0..<matrix[r].count {
                if matrix[r][c] == 1 {
                    let tx = x + c
                    let ty = y + r
                    if tx < 0 || tx >= currentGridSize || ty < 0 || ty >= currentGridSize { return false }
                    if board[ty][tx].isFilled { return false }
                }
            }
        }
        return true
    }

    // MARK: - Game Interaction

    func place(piece: BlockPiece, at x: Int, y: Int) {
        // 1. Önce Durumu Kaydet (Undo için)
        saveState()

        // 2. Board'a Yaz
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

        // 3. Tepsiden Sil
        if let idx = tray.firstIndex(where: { $0.id == piece.id }) {
            tray.remove(at: idx)
        }

        // 4. İlerlemeyi Güncelle
        piecesPlacedCount += 1

        HapticManager.shared.placePiece()

        // 5. YENİ KAZANMA KONTROLÜ: Tahta tamamen doldu mu?
        if checkWinCondition() {
            completeLevel()
            return // Kazandık, aşağıya (game over kontrolüne) inmeye gerek yok.
        }

        // 6. KAYBETME KONTROLÜ:
        // Tahta dolmadı AMA elimizdeki kalan parçalar boşluklara sığmıyor mu?
        checkGameOver()

        // Preview Temizle
        previewCells.removeAll()
    }

    func completeLevel() {
        gameStatus = "Victory!"
        let reward = difficulty.levelClearReward
        addCoins(amount: reward)

        // Level kaydet
        if currentLevel < LevelLibrary.totalLevels {
            UserDefaults.standard.set(currentLevel + 1, forKey: "userCurrentLevel")
            currentLevel += 1
        }

        // Modal aç
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadLevel(self.currentLevel)
            self.showLevelStartModal = true
            self.gameStatus = "Ready"
        }
    }

    func nextLevel() {
        if currentLevel < LevelLibrary.totalLevels {
            loadLevel(currentLevel + 1)
        } else {
            // Oyun bitti, başa dön veya tebrik et
            loadLevel(1)
        }
    }

    // MARK: - Shape Growing Algorithms (Standard)

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
                    if vGrid[sy + y][sx + x] == 0 { fits = false; break }
                }
                if !fits { break }
            }
            if fits {
                for y in 0..<h { for x in 0..<w { vGrid[sy + y][sx + x] = 0 } }
                let matrix = Array(repeating: Array(repeating: 1, count: w), count: h)
                return BlockPiece(matrix: matrix, color: getRandomColor(), targetX: sx, targetY: sy)
            }
        }
        return growBlob(vGrid: &vGrid, sx: sx, sy: sy, targetSize: targetSize)
    }

    private struct Point: Hashable { let x: Int; let y: Int }

    private func growBlob(vGrid: inout [[Int]], sx: Int, sy: Int, targetSize: Int) -> BlockPiece? {
        guard let rng = self.rng else { return nil }
        var region: [Point] = [Point(x: sx, y: sy)]
        vGrid[sy][sx] = 0
        var i = 0
        while region.count < targetSize && i < region.count {
            let current = region[i]
            var dirs = [[0,1], [0,-1], [1,0], [-1,0]]
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
        let minX = region.map { $0.x }.min() ?? 0
        let minY = region.map { $0.y }.min() ?? 0
        let maxX = region.map { $0.x }.max() ?? 0
        let maxY = region.map { $0.y }.max() ?? 0
        let width = maxX - minX + 1
        let height = maxY - minY + 1
        var matrix = Array(repeating: Array(repeating: 0, count: width), count: height)
        for p in region { matrix[p.y - minY][p.x - minX] = 1 }
        return BlockPiece(matrix: matrix, color: getRandomColor(), targetX: minX, targetY: minY)
    }

    // MARK: - Economy & Powerups

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

    // MARK: - Game Context Conformance & Joker Usage
    // Note: Conformance is declared in extension usually, but here for simplicity:
    // GameViewModel: GameContext
    
    // Joker Manager
    var jokerManager: JokerManager = .standard
    
    func useJoker(id: JokerType) {
//        if coins <= 100 { self.coins = 950 }
        guard let joker = jokerManager.getJoker(id: id) else { return }

        HapticManager.shared.useJoker()
        // Execute
        // We pass 'self' as context. 
        // Since execute returns Bool, we can handle feedback here if needed.
        withAnimation(Animation.easeIn.delay(0.05)) {
            let success = joker.execute(context: self)
            if !success {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }

    func useHint() {
        useJoker(id: .hint)
    }
    
    func triggerUndo() {
        useJoker(id: .undo)
    }
    
    func triggerJokerModal() {
        useJoker(id: .piece)
    }

    // --- FIND PLACEMENT (TARGET BASED) ---
    // GÜNCELLENMİŞ FIND PLACEMENT
    func findPlacement(for piece: BlockPiece) -> (x: Int, y: Int)? {
        if let tx = piece.targetX, let ty = piece.targetY {
            if canPlace(piece: piece, at: tx, y: ty) {
                return (tx, ty)
            }
        }
        for y in 0..<currentGridSize {
            for x in 0..<currentGridSize {
                if canPlace(piece: piece, at: x, y: y) {
                    return (x, y)
                }
            }
        }

        return nil
    }

    // MARK: - Helpers

    func createJokerPiece(matrix: [[Int]]) -> Bool {
        // Önce matrisi kırp (Gereksiz boşlukları at)
        let trimmedMatrix = trimMatrix(matrix)

        // Eğer boş bir şekil çizildiyse işlem yapma (veya uyarı ver)
        if trimmedMatrix.isEmpty { return false }

        if spendCoins(amount: 200) {
            // Kırpılmış matris ile parça oluştur
            let piece = BlockPiece(
                matrix: trimmedMatrix,
                color: "c-3", // Joker rengi
                targetX: nil,
                targetY: nil
            )

            // Tepsiye ekle
            tray.append(piece)
            return true
        }
        return false
    }

    // Matrisin etrafındaki boş (0) satır ve sütunları kesip atar
    private func trimMatrix(_ matrix: [[Int]]) -> [[Int]] {
        var minX = Int.max
        var maxX = -1
        var minY = Int.max
        var maxY = -1
        var hasOnes = false

        // 1. Sınırları (Bounding Box) bul
        for y in 0..<matrix.count {
            for x in 0..<matrix[y].count {
                if matrix[y][x] == 1 {
                    hasOnes = true
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }

        // Eğer matris tamamen boşsa (kullanıcı hiçbir şey çizmediyse)
        if !hasOnes { return [] }

        // 2. Yeni boyutları hesapla
        let height = maxY - minY + 1
        let width = maxX - minX + 1

        // 3. Yeni matrisi oluştur ve verileri kopyala
        var newMatrix = Array(repeating: Array(repeating: 0, count: width), count: height)

        for y in 0..<height {
            for x in 0..<width {
                // Orijinal matristen, hesaplanan offset'e göre veri al
                newMatrix[y][x] = matrix[minY + y][minX + x]
            }
        }

        return newMatrix
    }

    func findBestPlacement(nearGridX centerGx: Int, nearGridY centerGy: Int, piece: BlockPiece) -> (x: Int, y: Int)? {
        let offsetX = piece.matrix[0].count / 2
        let offsetY = piece.matrix.count / 2
        var bestX = -1, bestY = -1, minD = Double.infinity

        for dy in -1...1 {
            for dx in -1...1 {
                let csx = (centerGx + dx) - offsetX
                let csy = (centerGy + dy) - offsetY
                if canPlace(piece: piece, at: csx, y: csy) {
                    let dist = Double(dx*dx + dy*dy)
                    if dist < minD {
                        minD = dist
                        bestX = csx
                        bestY = csy
                    }
                }
            }
        }
        if bestX != -1 { return (bestX, bestY) }
        return nil
    }

    func updatePreview(nearGridX gX: Int, nearGridY gY: Int, piece: BlockPiece?) {
        guard let piece = piece else { previewCells.removeAll(); return }
        if let best = findBestPlacement(nearGridX: gX, nearGridY: gY, piece: piece) {
            var newPreview: Set<String> = []
            let matrix = piece.matrix
            for r in 0..<matrix.count {
                for c in 0..<matrix[r].count {
                    if matrix[r][c] == 1 {
                        newPreview.insert("\(best.x + c),\(best.y + r)")
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
        if difficulty == .god && rng.next() > 0.8 { return "c-god" }
        let idx = Int(rng.next() * Double(colors.count))
        return colors[min(idx, colors.count - 1)]
    }
}

