import Vapor

struct Prunelle: CharacterAlgorithm {
    let name = "Prunelle"
    let world = "GastonLagaffe"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#1B4332" // Dark stressed green
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Stress Algorithm: Rapid, sharp, jagged lines.
        var p = Point(x: rng.next(in: 0...grid.width - 1),
                      y: rng.next(in: 0...grid.height - 1))
        
        for _ in 0..<10 {
            let dx = rng.next(in: 0...1) == 0 ? 5 : -5
            let dy = rng.next(in: 0...1) == 0 ? 5 : -5
            
            for i in 0..<5 {
                grid.setCell(at: Point(x: p.x + (i * dx / 5), y: p.y + (i * dy / 5)), 
                             cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
            }
            p.x += dx
            p.y += dy
            if !grid.isValid(p) {
                p = Point(x: rng.next(in: 0...grid.width - 1), y: rng.next(in: 0...grid.height - 1))
            }
        }
    }
}
