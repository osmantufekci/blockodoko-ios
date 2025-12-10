import Foundation

class SeededRNG {
    private var seed: UInt32 = 0
    
    init(seedString: String) {
        self.seed = 0
        for char in seedString.unicodeScalars {
            // Equivalent to JS: (this.seed * 31 + charCode) >>> 0
            // We use wrapping arithmetic (&*) to simulate standard integer overflow behavior
            // and perform the operation on UInt32 directly.
            self.seed = (self.seed &* 31) &+ UInt32(char.value)
        }
        
        // Handle the 0 case same as JS
        if self.seed == 0 {
            self.seed = 123456
        }
    }
    
    /// Generates a random number between 0.0 (inclusive) and 1.0 (exclusive)
    func next() -> Double {
        // XORShift algorithm from the JS source
        // this.seed ^= this.seed << 13;
        self.seed ^= (self.seed << 13)
        // this.seed ^= this.seed >> 17;
        self.seed ^= (self.seed >> 17)
        // this.seed ^= this.seed << 5;
        self.seed ^= (self.seed << 5)
        
        // (this.seed >>> 0) / 4294967296
        // UInt32 is already unsigned, so >>> 0 is implicit
        return Double(self.seed) / 4294_967_296.0
    }
}
