import Vapor

struct Tigrou: CharacterAlgorithm {
    let name = "Tigrou"
    let world = "WinnieThePooh"
    let country = "UK"
    let region = "Europe"
    let colorHex = "#FB8500" // Tigger Orange
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Bouncy: High-frequency erratic jumps
        var p = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
        for _ in 0..<15 {
            let jumpX = rng.next(in: -15...15)
            let jumpY = rng.next(in: -15...15)
            let target = Point(x: p.x + jumpX, y: p.y + jumpY)
            
            // Draw the "bounce" path
            for i in 0...5 {
                let step = Point(x: p.x + (jumpX * i / 5), y: p.y + (jumpY * i / 5))
                let isStripe = i % 2 == 0
                grid.setCell(at: step, cell: Cell(color: isStripe ? "#000000" : colorHex, characterWorld: world, intensity: 3))
            }
            p = grid.isValid(target) ? target : Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
        }
    }
}
