import Vapor

struct Thor: CharacterAlgorithm {
    let name = "Thor"
    let world = "NorseMythology"
    let country = "Norway"
    let region = "Europe"
    let colorHex = "#00B4D8" // Lightning Blue
    let secondaryColorHex = "#FEE440" // Electric Yellow
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Lightning Strike: Jagged downward lines that branch out
        let strikes = 3
        
        for _ in 0..<strikes {
            var branches = [Point(x: rng.next(in: 0...grid.width-1), y: 0)]
            
            while !branches.isEmpty {
                let current = branches.removeFirst()
                
                // Draw current segment
                var p = current
                let segmentLength = rng.next(in: 5...15)
                
                for _ in 0..<segmentLength {
                    let color = rng.next(in: 0...10) > 2 ? colorHex : secondaryColorHex
                    grid.setCell(at: p, cell: Cell(color: color, characterWorld: world, intensity: 5))
                    
                    // Always move generally downwards
                    p.y += 1
                    p.x += rng.next(in: -1...1)
                    
                    if !grid.isValid(p) { break }
                }
                
                if !grid.isValid(p) { continue }
                
                // Chance to branch
                if rng.next(in: 0...100) < 40 {
                    // Branch left
                    branches.append(Point(x: p.x - 2, y: p.y))
                    // Branch right
                    branches.append(Point(x: p.x + 2, y: p.y))
                } else {
                    // Continue main strike
                    branches.append(p)
                }
            }
        }
    }
}
