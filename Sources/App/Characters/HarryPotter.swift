import Vapor
import Foundation

struct HarryPotter: CharacterAlgorithm {
    let name = "HarryPotter"
    let world = "WarnerBros"
    let country = "UK"
    let region = "Europe"
    let colorHex = "#FFFFFF" // Patronus White
    let glowHex = "#48CAE4" // Magic Cyan Glow
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Expecto Patronum: A bright, glowing, winding trail that gets thicker
        let start = Point(x: rng.next(in: 0...grid.width/4), y: rng.next(in: 0...grid.height-1))
        var current = start
        
        var angle = Double(rng.next(in: -45...45)) * .pi / 180.0
        
        for step in 1...30 {
            // Wavy magic path
            angle += Double(rng.next(in: -20...20)) * .pi / 180.0
            
            let dx = Int(Double(step) * cos(angle) * 0.5)
            let dy = Int(Double(step) * sin(angle) * 0.5)
            
            current = Point(x: start.x + dx, y: start.y + dy)
            
            // Core white light
            grid.setCell(at: current, cell: Cell(color: colorHex, characterWorld: world, intensity: 5))
            
            // Cyan Glow around it
            let glowSize = step / 10 + 1
            for gy in -glowSize...glowSize {
                for gx in -glowSize...glowSize {
                    if gx == 0 && gy == 0 { continue }
                    let p = Point(x: current.x + gx, y: current.y + gy)
                    if grid.getCell(at: p) == nil { // Don't overwrite the core
                        grid.setCell(at: p, cell: Cell(color: glowHex, characterWorld: world, intensity: 2))
                    }
                }
            }
        }
    }
}
