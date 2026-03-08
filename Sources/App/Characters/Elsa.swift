import Vapor

struct Elsa: CharacterAlgorithm {
    let name = "Elsa"
    let world = "Disney"
    let country = "USA" // Origin of studio, though set in Arendelle
    let region = "Americas"
    let colorHex = "#90E0EF" // Ice Blue
    let freezeHex = "#CAF0F8" // Light Snow
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Ice Fractals: Star patterns that freeze the surrounding area
        for _ in 0..<4 {
            let center = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 10...grid.height-10))
            let size = rng.next(in: 5...12)
            
            // 6-point snowflake
            let directions = [(0,-1), (0,1), (1,0), (-1,0), (1,-1), (-1,1), (-1,-1), (1,1)]
            
            for dir in directions {
                for i in 0...size {
                    let p = Point(x: center.x + dir.0 * i, y: center.y + dir.1 * i)
                    grid.setCell(at: p, cell: Cell(color: colorHex, characterWorld: world, intensity: 3))
                    
                    // Freeze surrounding
                    if rng.next(in: 0...10) > 6 {
                        grid.setCell(at: Point(x: p.x + 1, y: p.y), cell: Cell(color: freezeHex, characterWorld: world, intensity: 1))
                    }
                }
            }
        }
    }
}
