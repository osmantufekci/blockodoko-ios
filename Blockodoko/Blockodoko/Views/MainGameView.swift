import SwiftUI

struct MainGameView: View {
    let difficulty: Difficulty
    let seed: String?
    @StateObject private var viewModel = GameViewModel()

    // Drag State
    @State private var draggedPiece: BlockPiece?
    @State private var dragLocation: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var boardFrame: CGRect = .zero
    @State private var showJokerModal: Bool = false

    init(difficulty: Difficulty = .medHard, seed: String? = nil) {
        self.difficulty = difficulty
        self.seed = seed
    }

    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                // Header
                HeaderView(viewModel: viewModel)
                
                Spacer()
                
                // Game Board
                // We use GeometryReader to get the frame for drop detection
                GameBoardView(viewModel: viewModel, boardFrame: $boardFrame)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal)
                    .zIndex(1)
                 
                Spacer()
                
                // Controls (Undo, Hint)
                HStack(spacing: 20) {
                    Button(action: { viewModel.useHint() }) {
                        VStack {
                            Text("💡")
                            Text("Hint (100)")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                        .padding(8)
                        .background(Color.themeTray)
                        .cornerRadius(8)
                    }
                    
                    Button(action: { showJokerModal = true }) {
                        VStack {
                            Text("★")
                            Text("Joker (200)")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                        .padding(8)
                        .background(Color.themeTray)
                        .cornerRadius(8)
                    }
                }
                
                // Tray
                TrayView(
                    viewModel: viewModel,
                    draggedPiece: $draggedPiece,
                    dragLocation: $dragLocation,
                    dragOffset: $dragOffset
                )
                .simultaneousGesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            // Update Ghost Preview
                            updateGhost(location: value.location, piece: draggedPiece)
                        }
                        .onEnded { value in
                            handleDrop(location: value.location)
                        }
                )
                .padding(.bottom)

                LevelProgressView(
                    placed: viewModel.totalBlocks - viewModel.tray.count,
                    total: viewModel.totalBlocks
                )
                .padding(.bottom, 10)
            }
            .blur(radius: draggedPiece != nil ? 0.1 : 0)

            // Dragged Piece Overlay
            if let piece = draggedPiece {
                PieceView(piece: piece, cellSize: 40) // Larger size for dragging
                    .position(dragLocation)
                    .offset(y: -100) // Finger offset
                    .zIndex(100)
                    .allowsHitTesting(false)
            }
            
            // Modals
            if showJokerModal {
                JokerModalView(viewModel: viewModel, isPresented: $showJokerModal)
                    .zIndex(200)
            }
        }
        // status overlay
        .overlay(
            VStack {
                if viewModel.gameStatus == "Victory!" {
                    Text("VICTORY!")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.startLevel(difficulty: viewModel.difficulty)
                            viewModel.gameStatus = "Ready"
                        }
                }
            }
        )
        .onAppear {
            if viewModel.board.isEmpty {
                viewModel.startLevel(difficulty: difficulty, specificSeed: seed)
            }
        }
    }

    private func updateGhost(location: CGPoint, piece: BlockPiece?) {
        // AYAR 1: Offset'i -100 yerine -80 yaptık.
        // Eğer hala çok yüksekse -60 yap, çok alçaksa -120 yap.
        let yOffset: CGFloat = -50
        let piecePoint = CGPoint(x: location.x, y: location.y + yOffset)

        guard let piece = piece, boardFrame.contains(piecePoint) else {
            viewModel.updatePreview(nearGridX: -1, nearGridY: -1, piece: nil)
            return
        }

        let cellSize = (boardFrame.width - (2 * CGFloat(viewModel.board.count - 1))) / CGFloat(viewModel.board.count)
        let spacing: CGFloat = 2

        let relX = piecePoint.x - boardFrame.minX
        let relY = piecePoint.y - boardFrame.minY

        let unitSize = cellSize + spacing

        // AYAR 2: "rounded()" yerine direkt "Int()" kullanarak daha kararlı bir hesaplama yapıyoruz.
        // Bu, noktanın hangi karenin "içinde" olduğuna bakar.
        let gX = Int(relX / unitSize)
        let gY = Int(relY / unitSize)

        viewModel.updatePreview(nearGridX: gX, nearGridY: gY, piece: piece)
    }

    private func handleDrop(location: CGPoint) {
        guard let piece = draggedPiece else { return }

        viewModel.updatePreview(nearGridX: -1, nearGridY: -1, piece: nil)

        // AYAR 1: Buradaki offset değeri updateGhost ile AYNI olmalı (-80)
        let yOffset: CGFloat = -50
        let piecePoint = CGPoint(x: location.x, y: location.y + yOffset)

        if boardFrame.contains(piecePoint) {

            let cellSize = (boardFrame.width - (2 * CGFloat(viewModel.board.count - 1))) / CGFloat(viewModel.board.count)
            let spacing: CGFloat = 2

            let relX = piecePoint.x - boardFrame.minX
            let relY = piecePoint.y - boardFrame.minY

            let unitSize = cellSize + spacing

            // AYAR 2: Yuvarlama yerine Int kullanımı
            let gX = Int(relX / unitSize)
            let gY = Int(relY / unitSize)

            if let best = viewModel.findBestPlacement(nearGridX: gX, nearGridY: gY, piece: piece) {
                viewModel.place(piece: piece, at: best.x, y: best.y)

                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }

        draggedPiece = nil
        dragLocation = .zero
    }
}

#Preview {
    MainGameView(seed: "2T725OB1SU6")
}
