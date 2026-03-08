import Vapor

struct Batman: CharacterAlgorithm {
    let name = "Batman"
    let world = "DC"
    let country = "USA"
    let region = "Americas"
    let colorHex = "#212121" // Dark Knight
    let secondaryColorHex = "#FFEB3B" // Bat Signal Yellow
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Grapple Hook & Gliding: Sharp V-shapes and dropping from the top
        for _ in 0..<5 {
            let start = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 0...grid.height/2))
            
            // Bat-signal or bat-shape base
            grid.setCell(at: start, cell: Cell(color: secondaryColorHex, characterWorld: world, intensity: 5))
            
            let dropDepth = rng.next(in: 10...20)
            let spread = rng.next(in: 5...10)
            
            // Draw Cape/Grapple V-shape
            for i in 0...dropDepth {
                let leftPoint = Point(x: start.x - (i * spread / dropDepth), y: start.y + i)
                let rightPoint = Point(x: start.x + (i * spread / dropDepth), y: start.y + i)
                grid.setCell(at: leftPoint, cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
                grid.setCell(at: rightPoint, cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
            }
        }
    }
}
