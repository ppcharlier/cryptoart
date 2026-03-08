import Vapor

struct Winnie: CharacterAlgorithm {
    let name = "Winnie"
    let world = "WinnieThePooh"
    let country = "UK"
    let region = "Europe"
    let colorHex = "#FFC300" // Honey Yellow
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Honey Seeker: Spiraling movements around "sweet spots"
        for _ in 0..<3 {
            var center = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 10...grid.height-10))
            for radius in 1...5 {
                for i in 0..<8 {
                    let dx = Int(Double(radius) * cos(Double(i) * 0.8))
                    let dy = Int(Double(radius) * sin(Double(i) * 0.8))
                    grid.setCell(at: Point(x: center.x + dx, y: center.y + dy), 
                                 cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
                }
            }
        }
    }
}
