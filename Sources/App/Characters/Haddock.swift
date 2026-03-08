import Vapor

struct Haddock: CharacterAlgorithm {
    let name = "Haddock"
    let world = "Tintin"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#9B2226"
    let secondaryColorHex = "#0A9396" // Sea green
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Erratic Walk: Moves randomly 1 cell at a time.
        var currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                 y: rng.next(in: 0...grid.height - 1))
        
        let steps = grid.width * grid.height / 4 // Quite dense
        
        for _ in 0..<steps {
            // High chance of stumbling / clustering
            let color = rng.next(in: 0...10) > 8 ? secondaryColorHex : colorHex
            
            grid.setCell(at: currentPoint, cell: Cell(color: color, characterWorld: world, intensity: 3))
            
            let dirX = rng.next(in: -1...1)
            let dirY = rng.next(in: -1...1)
            
            let nextPoint = Point(x: currentPoint.x + dirX, y: currentPoint.y + dirY)
            if grid.isValid(nextPoint) {
                currentPoint = nextPoint
            } else {
                // If out of bounds, jump to a new random location (a very drunken teleport)
                currentPoint = Point(x: rng.next(in: 0...grid.width - 1),
                                     y: rng.next(in: 0...grid.height - 1))
            }
        }
    }
}
