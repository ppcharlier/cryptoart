import Vapor

struct Bourriquet: CharacterAlgorithm {
    let name = "Bourriquet"
    let world = "WinnieThePooh"
    let country = "UK"
    let region = "Europe"
    let colorHex = "#90A4AE" // Sad Blue-Grey
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Melancholic Drift: Slow vertical or diagonal lines that always feel "heavy"
        for _ in 0..<8 {
            var p = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height/2))
            let length = rng.next(in: 10...20)
            for _ in 0..<length {
                grid.setCell(at: p, cell: Cell(color: colorHex, characterWorld: world, intensity: 1))
                p.y += 1 // Gravity
                if rng.next(in: 0...1) == 0 { p.x += (rng.next(in: 0...1) == 0 ? 1 : -1) }
                if !grid.isValid(p) { break }
            }
        }
    }
}
