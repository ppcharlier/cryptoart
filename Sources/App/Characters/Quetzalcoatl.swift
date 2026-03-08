import Vapor
import Foundation

struct Quetzalcoatl: CharacterAlgorithm {
    let name = "Quetzalcoatl"
    let world = "AztecMythology"
    let country = "Mexico"
    let region = "Americas"
    let colorHex = "#2A9D8F" // Feather Green
    let secondaryColorHex = "#E76F51" // Serpent Red
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // The Feathered Serpent: Long, winding sinusoidal waves
        let waves = 3
        for _ in 0..<waves {
            let startY = rng.next(in: 10...grid.height-10)
            let amplitude = Double(rng.next(in: 3...10))
            let frequency = Double(rng.next(in: 5...15)) / 100.0
            
            for x in 0..<grid.width {
                // Calculate y based on sine wave
                let yOffset = Int(amplitude * sin(Double(x) * frequency))
                let y = startY + yOffset
                
                let p = Point(x: x, y: y)
                // Alternate between green and red
                let color = rng.next(in: 0...10) > 8 ? secondaryColorHex : colorHex
                grid.setCell(at: p, cell: Cell(color: color, characterWorld: world, intensity: 3))
                
                // Add thickness to the serpent
                grid.setCell(at: Point(x: x, y: y+1), cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
                grid.setCell(at: Point(x: x, y: y-1), cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
            }
        }
    }
}
