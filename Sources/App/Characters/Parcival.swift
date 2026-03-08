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
        // We look for a special context or just use a default set of keys if not provided
        // Since we can't easily pass the recipe here, we'll use the rng to decide 
        // how many keys to generate if no specific instructions are found.
        
        let numKeys = max(3, grid.width / 30) 
        var keys: [String] = []
        
        for i in 0..<numKeys {
            let base = "\(rng.next())-\(i)"
            if i % 3 == 0 { keys.append(sha256(base)) }
            else if i % 3 == 1 { keys.append(UUID().uuidString) }
            else { keys.append(sha512(base)) }
        }
        
        // 2. The Trials: Each key draws a path
        let colors = ["#4A4E69", "#95A5A6", "#F39C12", "#2A9D8F", "#E76F51", "#264653"]
        
        for (index, key) in keys.enumerated() {
            let color = colors[index % colors.count]
            drawKeyPath(grid: grid, key: key, color: color, intensity: 2 + (index % 3))
        }
        
        // 3. The Grail: Appears at a spot influenced by the first and last key
        if let first = keys.first, let last = keys.last {
            let grailX = abs(first.hashValue % grid.width)
            let grailY = abs(last.hashValue % grid.height)
            let grailCenter = Point(x: grailX, y: grailY)
            
            for r in 0...max(2, numKeys/2) {
                for i in 0..<8 {
                    let dx = Int(Double(r) * cos(Double(i) * 0.8))
                    let dy = Int(Double(r) * sin(Double(i) * 0.8))
                    grid.setCell(at: Point(x: grailCenter.x + dx, y: grailCenter.y + dy), 
                                 cell: Cell(color: grailHex, characterWorld: world, intensity: 5))
                }
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
