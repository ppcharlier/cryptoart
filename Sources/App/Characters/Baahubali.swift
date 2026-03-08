import Vapor
import Foundation

struct Baahubali: CharacterAlgorithm {
    let name = "Baahubali"
    let world = "Bollywood" // Tollywood technically, but part of Indian Cinema
    let country = "India"
    let region = "Asia"
    let colorHex = "#FFB703" // Golden armor
    let secondaryColorHex = "#780000" // Royal Red
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Epic Sweeps: Massive semi-circular sword arcs
        for _ in 0..<3 {
            let center = Point(x: rng.next(in: 0...grid.width), y: rng.next(in: 0...grid.height))
            let radius = Double(rng.next(in: 15...30))
            let startAngle = Double(rng.next(in: 0...180)) * .pi / 180.0
            let endAngle = startAngle + Double(rng.next(in: 90...180)) * .pi / 180.0
            
            let steps = Int(radius * 2)
            for i in 0...steps {
                let currentAngle = startAngle + (endAngle - startAngle) * (Double(i) / Double(steps))
                
                // Thick blade
                for thickness in 0...2 {
                    let r = radius + Double(thickness)
                    let x = center.x + Int(r * cos(currentAngle))
                    let y = center.y + Int(r * sin(currentAngle))
                    
                    let color = rng.next(in: 0...10) > 2 ? colorHex : secondaryColorHex
                    grid.setCell(at: Point(x: x, y: y), cell: Cell(color: color, characterWorld: world, intensity: 4))
                }
            }
        }
    }
}
