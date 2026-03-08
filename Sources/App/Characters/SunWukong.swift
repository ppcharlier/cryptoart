import Vapor

struct SunWukong: CharacterAlgorithm {
    let name = "SunWukong"
    let world = "JourneyToTheWest"
    let country = "China"
    let region = "Asia"
    let colorHex = "#D4AF37" // Golden Staff
    let cloudColorHex = "#E0E1DD" // Nimbus Cloud
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Nimbus & Staff: Sweeping cloud arcs and perfectly straight striking lines
        
        // 1. Draw Nimbus Clouds (horizontal clustered arcs)
        for _ in 0..<4 {
            let start = Point(x: rng.next(in: 0...grid.width/2), y: rng.next(in: 0...grid.height-1))
            let length = rng.next(in: 15...30)
            
            for i in 0..<length {
                let x = start.x + i
                // Wavy y offset
                let yOffset = rng.next(in: -1...1)
                let p = Point(x: x, y: start.y + yOffset)
                
                // Cloud puff (3x3 brush roughly)
                for dy in -1...1 {
                    for dx in -1...1 {
                        if rng.next(in: 0...10) > 3 {
                            grid.setCell(at: Point(x: p.x+dx, y: p.y+dy), cell: Cell(color: cloudColorHex, characterWorld: world, intensity: 2))
                        }
                    }
                }
            }
        }
        
        // 2. The Golden Staff (Ruyi Jingu Bang) - Perfect, infinite lines
        for _ in 0..<2 {
            let staffX = rng.next(in: 0...grid.width-1)
            let isVertical = rng.next(in: 0...1) == 0
            
            if isVertical {
                for y in 0..<grid.height {
                    grid.setCell(at: Point(x: staffX, y: y), cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
                }
            } else {
                let staffY = rng.next(in: 0...grid.height-1)
                for x in 0..<grid.width {
                    grid.setCell(at: Point(x: x, y: staffY), cell: Cell(color: colorHex, characterWorld: world, intensity: 4))
                }
            }
        }
    }
}
