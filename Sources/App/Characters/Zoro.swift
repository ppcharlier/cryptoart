import Vapor

struct Zoro: CharacterAlgorithm {
    let name = "Zoro"
    let world = "OnePiece"
    let country = "Japan"
    let region = "Asia"
    let colorHex = "#2D6A4F" // Sword Green
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Santoryu: 3 parallel diagonal slashes
        for _ in 0..<3 {
            let start = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
            let len = rng.next(in: 10...30)
            let dir = rng.next(in: 0...1) == 0 ? 1 : -1
            
            for i in 0..<len {
                // Three parallel lines
                for offset in -1...1 {
                    let p = Point(x: start.x + i, y: start.y + (i * dir) + offset)
                    grid.setCell(at: p, cell: Cell(color: colorHex, characterWorld: world, intensity: 3))
                }
            }
        }
    }
}
