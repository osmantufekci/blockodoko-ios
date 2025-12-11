import Foundation

final class SeededRNG {
    private var seed: UInt32 = 0
    
    init(seedString: String) {
        self.seed = 0
        for char in seedString.unicodeScalars {
            self.seed = (self.seed &* 31) &+ UInt32(char.value)
        }
        
        if self.seed == 0 {
            self.seed = 123456
        }
    }

    func next() -> Double {
        self.seed ^= (self.seed << 13)
        self.seed ^= (self.seed >> 17)
        self.seed ^= (self.seed << 5)

        return Double(self.seed) / 4294_967_296.0
    }
}
