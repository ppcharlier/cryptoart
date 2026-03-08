import Vapor

struct SpiderMan: CharacterAlgorithm {
    let name = "SpiderMan"
    let world = "Marvel"
    let country = "USA"
    let region = "Americas"
    let colorHex = "#E63946" // Spidey Red
    let webColorHex = "#F1FAEE" // Web White
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Web slinging: Intersecting lines across the whole canvas
        for _ in 0..<4 {
            let anchorX = rng.next(in: 0...grid.width-1)
            let anchorY = rng.next(in: 0...grid.height/3) // Webs usually anchor high
            
            let numWebs = rng.next(in: 3...6)
            for _ in 0..<numWebs {
                let targetX = rng.next(in: 0...grid.width-1)
                let targetY = rng.next(in: grid.height/2...grid.height-1)
                
                let steps = 30
                for i in 0...steps {
                    let x = anchorX + (targetX - anchorX) * i / steps
                    let y = anchorY + (targetY - anchorY) * i / steps
                    grid.setCell(at: Point(x: x, y: y), cell: Cell(color: webColorHex, characterWorld: world, intensity: 2))
                }
                // Spidey swings at the end
                grid.setCell(at: Point(x: targetX, y: targetY), cell: Cell(color: colorHex, characterWorld: world, intensity: 5))
            }
        }
    }
}
