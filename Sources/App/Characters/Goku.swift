import Vapor

struct Goku: CharacterAlgorithm {
    let name = "Goku"
    let world = "DragonBall"
    let country = "Japan"
    let region = "Asia"
    let colorHex = "#FB8500" // Gi Orange
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Instant Transmission & Kamehameha: Teleports and radial bursts
        for _ in 0..<4 {
            let p = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 10...grid.height-10))
            
            // Energy burst
            for r in 1...6 {
                for _ in 0..<r*2 {
                    let dx = rng.next(in: -r...r)
                    let dy = rng.next(in: -r...r)
                    grid.setCell(at: Point(x: p.x + dx, y: p.y + dy), 
                                 cell: Cell(color: r % 2 == 0 ? colorHex : "#219ebc", characterWorld: world, intensity: 5))
                }
            }
        }
    }
}
