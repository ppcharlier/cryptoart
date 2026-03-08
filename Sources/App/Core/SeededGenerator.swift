import Vapor

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    init(hashString: String) {
        // Simple djb2 hash to derive a UInt64 seed from the string
        let hash = hashString.utf8.reduce(5381 as UInt64) { (result, char) in
            let res = (result &<< 5) &+ result &+ UInt64(char)
            return res
        }
        self.state = hash == 0 ? 1 : hash
    }
    
    mutating func next() -> UInt64 {
        // Simple Linear Congruential Generator (LCG)
        // Constants from Knuth MMIX
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
    
    // Helper to get a random Int in a range
    mutating func next(in range: ClosedRange<Int>) -> Int {
        let upperBound = UInt64(range.upperBound - range.lowerBound)
        let randomValue = next() % (upperBound + 1)
        return range.lowerBound + Int(randomValue)
    }
}
