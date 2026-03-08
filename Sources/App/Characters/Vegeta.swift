import Vapor

struct Vegeta: CharacterAlgorithm {
    let name = "Vegeta"
    let world = "DragonBall"
    let country = "Japan"
    let region = "Asia"
    let colorHex = "#5E548E" // Galick Gun Purple
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Galick Gun: Massive diagonal energy beams from corners
        let corner = Point(x: rng.next(in: 0...1) * grid.width, y: rng.next(in: 0...1) * grid.height)
        for _ in 0..<2 {
            let target = Point(x: rng.next(in: 0...grid.width), y: rng.next(in: 0...grid.height))
            for i in 0...20 {
                let p = Point(x: corner.x + (target.x - corner.x) * i / 20, 
                              y: corner.y + (target.y - corner.y) * i / 20)
                // Thick beam
                for r in -2...2 {
                    grid.setCell(at: Point(x: p.x + r, y: p.y), cell: Cell(color: colorHex, characterWorld: world, intensity: 5))
                }
            }
        }
    }
}
