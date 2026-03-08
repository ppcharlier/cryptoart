import Vapor
import Crypto
import Foundation

struct Parcival: CharacterAlgorithm {
    let name = "Parcival"
    let world = "ArthurianLegends"
    let country = "UK"
    let region = "Europe"
    let colorHex = "#E63946" // Knightly Red
    let grailHex = "#FFD700" // Grail Gold
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // 1. Generate the 3 Sacred Keys
        let baseSeed = "\(rng.next())"
        
        let ironKey = sha256(baseSeed)
        let silverKey = UUID().uuidString
        let goldenKey = sha512(baseSeed)
        
        // 2. The Trials: Each key draws a path
        drawKeyPath(grid: grid, key: ironKey, color: "#4A4E69", intensity: 2)   // Iron Path
        drawKeyPath(grid: grid, key: silverKey, color: "#95A5A6", intensity: 3) // Silver Path
        drawKeyPath(grid: grid, key: goldenKey, color: "#F39C12", intensity: 4) // Golden Path
        
        // 3. The Grail: Intersection points become Gold
        // (Simple implementation: place a Grail burst at a deterministic spot based on all keys)
        let grailX = abs(goldenKey.hashValue % grid.width)
        let grailY = abs(ironKey.hashValue % grid.height)
        let grailCenter = Point(x: grailX, y: grailY)
        
        for r in 0...4 {
            for i in 0..<8 {
                let dx = Int(Double(r) * cos(Double(i) * 0.8))
                let dy = Int(Double(r) * sin(Double(i) * 0.8))
                grid.setCell(at: Point(x: grailCenter.x + dx, y: grailCenter.y + dy), 
                             cell: Cell(color: grailHex, characterWorld: world, intensity: 5))
            }
        }
    }
    
    private func drawKeyPath(grid: Grid, key: String, color: String, intensity: Int) {
        var current = Point(x: abs(key.prefix(4).hashValue % grid.width), 
                            y: abs(key.suffix(4).hashValue % grid.height))
        
        let steps = 20
        let keyData = Array(key)
        
        for i in 0..<steps {
            grid.setCell(at: current, cell: Cell(color: color, characterWorld: world, intensity: intensity))
            
            // Movement derived from characters of the key
            let charIndex = i % keyData.count
            let move = Int(keyData[charIndex].asciiValue ?? 0)
            
            current.x = (current.x + (move % 3 - 1) + grid.width) % grid.width
            current.y = (current.y + (move / 3 % 3 - 1) + grid.height) % grid.height
        }
    }
    
    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func sha512(_ input: String) -> String {
        let digest = SHA512.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
