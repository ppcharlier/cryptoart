import Vapor
import Crypto
import Foundation

struct PPP: CharacterAlgorithm {
    let name = "PPP"
    let world = "PierrePrincessPrincipal"
    let country = "France"
    let region = "Europe"
    let colorHex = "#6D597A" // Royal Muted Purple
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // PPP knows what it does, even when it ignores it.
        // It uses 4 distinct deterministic passes.
        
        let baseSeed = "\(rng.next())"
        
        // Pass 1: The Princess Foundation (Background textures)
        drawPrincessFoundation(grid: grid, seed: sha256(baseSeed + "princess"))
        
        // Pass 2: The Principal Structures (Bold architectural lines)
        drawPrincipalStructures(grid: grid, seed: sha256(baseSeed + "principal"))
        
        // Pass 3: The Pierre Flourishes (Dynamic detail)
        drawPierreFlourishes(grid: grid, seed: sha256(baseSeed + "pierre"))
        
        // Pass 4: The Scalable Harmony (Final balance)
        drawScalableHarmony(grid: grid, seed: sha256(baseSeed + "harmony"))
    }
    
    private func drawPrincessFoundation(grid: Grid, seed: String) {
        // Large rectangular blocks of varying opacity (intensity)
        var prng = SeededGenerator(hashString: seed)
        let colors = ["#B5838D", "#E5989B", "#FFB4A2"]
        
        for _ in 0..<10 {
            let w = prng.next(in: 10...grid.width/2)
            let h = prng.next(in: 10...grid.height/2)
            let x = prng.next(in: 0...grid.width-w)
            let y = prng.next(in: 0...grid.height-h)
            let color = colors.randomElement()!
            
            for dy in 0..<h {
                for dx in 0..<w {
                    grid.setCell(at: Point(x: x+dx, y: y+dy), cell: Cell(color: color, characterWorld: world, intensity: 1))
                }
            }
        }
    }
    
    private func drawPrincipalStructures(grid: Grid, seed: String) {
        // Bold diagonal or vertical pillars
        var prng = SeededGenerator(hashString: seed)
        let color = "#355070" // Deep Blue
        
        for _ in 0..<5 {
            let isVertical = prng.next(in: 0...1) == 0
            if isVertical {
                let x = prng.next(in: 0...grid.width-1)
                for y in 0..<grid.height {
                    grid.setCell(at: Point(x: x, y: y), cell: Cell(color: color, characterWorld: world, intensity: 4))
                }
            } else {
                let startY = prng.next(in: 0...grid.height-1)
                for x in 0..<grid.width {
                    let y = (startY + (x / 2)) % grid.height
                    grid.setCell(at: Point(x: x, y: y), cell: Cell(color: color, characterWorld: world, intensity: 3))
                }
            }
        }
    }
    
    private func drawPierreFlourishes(grid: Grid, seed: String) {
        // Fine cryptographic details
        var prng = SeededGenerator(hashString: seed)
        let color = "#EAAC8B" // Soft Orange
        
        for _ in 0..<50 {
            let x = prng.next(in: 0...grid.width-1)
            let y = prng.next(in: 0...grid.height-1)
            // Tiny 2x2 clusters
            for dy in 0...1 {
                for dx in 0...1 {
                    grid.setCell(at: Point(x: x+dx, y: y+dy), cell: Cell(color: color, characterWorld: world, intensity: 5))
                }
            }
        }
    }
    
    private func drawScalableHarmony(grid: Grid, seed: String) {
        // Final pass to blend or erase slightly for "air"
        var prng = SeededGenerator(hashString: seed)
        for _ in 0..<20 {
            let x = prng.next(in: 0...grid.width-1)
            let y = prng.next(in: 0...grid.height-1)
            if prng.next(in: 0...10) > 7 {
                grid.setCell(at: Point(x: x, y: y), cell: Cell(color: nil, intensity: 0)) // Erasure for breathing room
            }
        }
    }

    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
