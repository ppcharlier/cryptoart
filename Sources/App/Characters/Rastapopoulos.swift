import Vapor

struct Rastapopoulos: CharacterAlgorithm {
    let name = "Rastapopoulos"
    let world = "Tintin"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#1D3557" // Dark plotting navy
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // The Plot: Creates dark blocks that "cover" other art
        for _ in 0..<3 {
            let start = Point(x: rng.next(in: 0...grid.width-10), y: rng.next(in: 0...grid.height-10))
            let w = rng.next(in: 4...8)
            let h = rng.next(in: 4...8)
            
            for dy in 0..<h {
                for dx in 0..<w {
                    grid.setCell(at: Point(x: start.x + dx, y: start.y + dy), 
                                 cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
                }
            }
        }
    }
}
