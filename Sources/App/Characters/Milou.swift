import Vapor

struct Milou: CharacterAlgorithm {
    let name = "Milou"
    let world = "Tintin"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#FFFFFF" // Snowy White
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Small, nervous clusters near random points
        for _ in 0..<15 {
            let p = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
            for _ in 0..<3 {
                let offset = Point(x: p.x + rng.next(in: -1...1), y: p.y + rng.next(in: -1...1))
                grid.setCell(at: offset, cell: Cell(color: colorHex, characterWorld: world, intensity: 1))
            }
        }
    }
}
