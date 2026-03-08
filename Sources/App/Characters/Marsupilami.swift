import Vapor

struct Marsupilami: CharacterAlgorithm {
    let name = "Marsupilami"
    let world = "Marsupilami"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#FFB703"
    let spotColorHex = "#023047" // Black/Dark blue spots
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Spring bounce: moves in arcs or big jumps
        var currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                 y: rng.next(in: 0...grid.height - 1))
        
        let jumps = 20
        
        for _ in 0..<jumps {
            let jumpDistance = rng.next(in: 3...10)
            let dirX = rng.next(in: -1...1)
            let dirY = rng.next(in: -1...1)
            
            for step in 0..<jumpDistance {
                let p = Point(x: currentPoint.x + dirX * step, y: currentPoint.y + dirY * step)
                if grid.isValid(p) {
                    // Mostly yellow, occasionally spots
                    let isSpot = rng.next(in: 0...100) < 15
                    let c = isSpot ? spotColorHex : colorHex
                    grid.setCell(at: p, cell: Cell(color: c, characterWorld: world, intensity: isSpot ? 4 : 2))
                }
            }
            
            // End jump point
            currentPoint = Point(x: currentPoint.x + dirX * jumpDistance, y: currentPoint.y + dirY * jumpDistance)
            
            // Keep in bounds roughly
            currentPoint.x = max(0, min(grid.width - 1, currentPoint.x))
            currentPoint.y = max(0, min(grid.height - 1, currentPoint.y))
        }
    }
}
