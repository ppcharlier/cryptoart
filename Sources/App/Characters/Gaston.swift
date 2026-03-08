import Vapor

struct Gaston: CharacterAlgorithm {
    let name = "Gaston"
    let world = "GastonLagaffe"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#2D6A4F" // Gaston's green sweater
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Chaos Algorithm: Moves randomly but has a 10% chance to "gaffe" 
        // which erases a 3x3 area or creates a random color explosion.
        var currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                 y: rng.next(in: 0...grid.height - 1))
        
        for _ in 0..<100 {
            if rng.next(in: 0...100) < 10 {
                // A Gaffe! Erase or explode
                let size = 2
                for dy in -size...size {
                    for dx in -size...size {
                        let p = Point(x: currentPoint.x + dx, y: currentPoint.y + dy)
                        if rng.next(in: 0...1) == 0 {
                            grid.setCell(at: p, cell: Cell(color: nil, intensity: 0)) // Erase
                        } else {
                            grid.setCell(at: p, cell: Cell(color: "#FF5400", intensity: 5)) // Explosion
                        }
                    }
                }
            } else {
                grid.setCell(at: currentPoint, cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
            }
            
            currentPoint = Point(x: currentPoint.x + rng.next(in: -2...2),
                                 y: currentPoint.y + rng.next(in: -2...2))
            
            if !grid.isValid(currentPoint) {
                currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                     y: rng.next(in: 0...grid.height - 1))
            }
        }
    }
}
