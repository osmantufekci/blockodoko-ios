import Foundation
import Combine

class JokerManager: ObservableObject {
    @Published var availableJokers: [any JokerProtocol] = []
    
    init(jokers: [any JokerProtocol]) {
        self.availableJokers = jokers
    }
    
    // Default Configuration
    static let standard = JokerManager(jokers: [
        HintJoker(),
        JokerPieceJoker(),
        UndoJoker()
    ])
    
    func getJoker(id: JokerType) -> (any JokerProtocol)? {
        return availableJokers.first { $0.id == id }
    }
}
