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
    @State private var trayFrame: CGRect = .zero
    @State private var isReturning: Bool = false
    @State private var targetLocation: CGPoint? = nil

    init(difficulty: Difficulty = .medHard, seed: String? = nil) {
        self.difficulty = difficulty
        self.seed = seed
    }

    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                HeaderView(viewModel: viewModel)
                
                Spacer()

                GameBoardView(
                    viewModel: viewModel,
                    boardFrame: $boardFrame,
                    onLiftPiece: { piece, location in
                        if draggedPiece == nil {
                            HapticManager.shared.liftPiece()
                            draggedPiece = piece
                            dragLocation = location
                            dragOffset = .zero
                        }
                    },
                    onDragChanged: { location in
                        if draggedPiece != nil {
                            dragLocation = location
                            updateGhost(location: location, piece: draggedPiece)
                        }
                    },
                    onDragEnded: { location in
                        if draggedPiece != nil {
                            handleDrop(location: location)
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal)
                .zIndex(1)
                 
                Spacer()

                HStack(spacing: 20) {
                    ForEach(viewModel.jokerManager.availableJokers, id: \.id) { joker in
                         Button(action: { 
                             viewModel.useJoker(id: joker.id) 
                         }) {
                            VStack {
                                Image(systemName: joker.icon)
                                    .font(.system(size: 20))
                                Text(joker.name)
                                    .font(.caption2)
                            }
                            .foregroundColor(joker.color)
                            .padding(8)
                            .background(Color.themeTray)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 8)

                TrayView(
                    viewModel: viewModel,
                    draggedPiece: $draggedPiece,
                    dragLocation: $dragLocation,
                    dragOffset: $dragOffset,
                    trayFrame: $trayFrame
                )
                .simultaneousGesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            if targetLocation == nil {
                                targetLocation = value.location
                            }
                            updateGhost(location: value.location, piece: draggedPiece)
                        }
                        .onEnded { value in
                            handleDrop(location: value.location)
                            targetLocation = nil
                        }
                )
                .padding(.bottom)

                LevelProgressView(
                    placed: viewModel.totalPiecesTarget - viewModel.tray.count,
                    total: viewModel.totalPiecesTarget
                )
                .padding(.bottom, 10)
            }
            .blur(radius: (draggedPiece != nil || viewModel.showLevelStartModal) ? 0.1 : 0)

            if let piece = draggedPiece {
                PieceView(piece: piece, cellSize: 40)
                    .scaleEffect(1.1)
                    .position(dragLocation)
                    .offset(y: -100)
                    .zIndex(100)
                    .allowsHitTesting(false)
                    .animation(.spring(), value: isReturning)
            }

            // Modals
            if viewModel.showJokerModal {
                JokerModalView(viewModel: viewModel, isPresented: $viewModel.showJokerModal)
                    .zIndex(200)
                    .opacity(0.75)
            }

            if viewModel.showLevelStartModal {
                LevelStartView(
                    levelNumber: viewModel.currentLevel,
                    gridSize: viewModel.board.count,
                    targetPieces: viewModel.tray.count,
                    difficultyName: viewModel.difficulty.rawValue,
                    onStart: {
                        withAnimation {
                            viewModel.showLevelStartModal = false
                        }
                    }
                )
                .zIndex(100)
            }

            if viewModel.showGameOverModal {
                GameOverView(
                    coins: viewModel.coins,
                    onRestart: {
                        viewModel.loadLevel(self.viewModel.currentLevel)
                        viewModel.gameStatus = .ready
                        viewModel.showGameOverModal = false
                    },
                    onUndo: {
                        viewModel.gameStatus = .playing
                        viewModel.showGameOverModal = false

                        withAnimation(Animation.easeIn.delay(0.25)) {
                            if viewModel.coins >= JokerManager.standard.getJoker(id: .undo)?.cost ?? 100 {
                                viewModel.undoMove()
                            }
                        }
                    }
                )
            }
        }
        .overlay(
            VStack {
                if viewModel.gameStatus == .victory {
                    ConfettiView()
                        .zIndex(299)
                        .allowsHitTesting(false)
                }
            }
        )
        .onAppear {
            if viewModel.board.isEmpty {
                viewModel.loadLevel(viewModel.currentLevel)
            }
        }
    }

    private func updateGhost(location: CGPoint, piece: BlockPiece?) {
        // AYAR 1: Offset'i -100 yerine -80 yaptık.
        // Eğer hala çok yüksekse -60 yap, çok alçaksa -120 yap.
        let yOffset: CGFloat = -30
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
        let pieceVisualCenter = CGPoint(x: location.x + dragOffset.width, y: location.y + dragOffset.height)

        let yOffset: CGFloat = -30
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

                HapticManager.shared.placePiece()

                draggedPiece = nil
                dragLocation = .zero
                dragOffset = .zero
                return
            }
        }

        animateReturnToTray(piece: piece)
    }

    private func animateReturnToTray(piece: BlockPiece) {
        HapticManager.shared.error()

        isReturning = true

        let targetX = targetLocation?.x ?? trayFrame.midX
        let targetY = targetLocation?.y ?? trayFrame.midY

        withAnimation(.smooth(duration: 0.2)) {
            dragLocation = CGPoint(x: targetX, y: targetY)
            dragOffset = .zero
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.returnPieceToTray(piece)

            draggedPiece = nil
            isReturning = false
        }
    }
}

#Preview {
    MainGameView(seed: "2T725OB1SU6")
}
