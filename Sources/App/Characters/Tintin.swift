import Vapor

struct Tintin: CharacterAlgorithm {
    let name = "Tintin"
    let world = "Tintin"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#0077B6"
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Ligne Claire: Straight, orthogonal lines. Turns 90 degrees randomly or at edges.
        var currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                 y: rng.next(in: 0...grid.height - 1))
        
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        var currentDirIndex = rng.next(in: 0...3)
        
        // Draw 5 long lines
        for _ in 0..<5 {
            let lineLength = rng.next(in: 5...25)
            
            for _ in 0..<lineLength {
                grid.setCell(at: currentPoint, cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
                
                let nextPoint = Point(x: currentPoint.x + directions[currentDirIndex].0,
                                      y: currentPoint.y + directions[currentDirIndex].1)
                
                if !grid.isValid(nextPoint) {
                    // Turn if hitting a wall
                    currentDirIndex = (currentDirIndex + (rng.next(in: 0...1) == 0 ? 1 : 3)) % 4
                } else {
                    currentPoint = nextPoint
                }
                
                // Slight chance to turn randomly
                if rng.next(in: 0...100) < 5 {
                    currentDirIndex = (currentDirIndex + (rng.next(in: 0...1) == 0 ? 1 : 3)) % 4
                }
            }
        }
    }
}
