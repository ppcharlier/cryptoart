import Vapor

struct Luffy: CharacterAlgorithm {
    let name = "Luffy"
    let world = "OnePiece"
    let country = "Japan"
    let region = "Asia"
    let colorHex = "#D00000" // Red Vest
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Gum-Gum Stretch: Long lines that span the grid and "snap"
        for _ in 0..<5 {
            let start = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
            let end = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
            
            // Draw a thick elastic line
            let steps = 20
            for i in 0...steps {
                let x = start.x + (end.x - start.x) * i / steps
                let y = start.y + (end.y - start.y) * i / steps
                grid.setCell(at: Point(x: x, y: y), cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
                // Add a yellow "hat" spark at the end
                if i == steps {
                    grid.setCell(at: Point(x: x+1, y: y), cell: Cell(color: "#FFB703", intensity: 5))
                }
            }
        }
    }
}
