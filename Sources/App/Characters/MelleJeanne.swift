import Vapor

struct MelleJeanne: CharacterAlgorithm {
    let name = "MelleJeanne"
    let world = "GastonLagaffe"
    let country = "Belgium"
    let region = "Europe"
    let colorHex = "#FF85A1" // Soft pink
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Hesitant Algorithm: Stays in small clusters, moving very slowly.
        for _ in 0..<5 {
            var center = Point(x: rng.next(in: 0...grid.width - 1),
                               y: rng.next(in: 0...grid.height - 1))
            
            for _ in 0..<20 {
                grid.setCell(at: center, cell: Cell(color: colorHex, characterWorld: world, intensity: 1))
                center.x += rng.next(in: -1...1)
                center.y += rng.next(in: -1...1)
                if !grid.isValid(center) { break }
            }
        }
    }
}
