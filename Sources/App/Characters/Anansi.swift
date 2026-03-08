import Vapor

struct Anansi: CharacterAlgorithm {
    let name = "Anansi"
    let world = "AkanMythology"
    let country = "Ghana" // Origin
    let region = "Africa"
    let colorHex = "#B8860B" // Golden thread
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // The Spider: Draws a radiating web from a random center
        let center = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 10...grid.height-10))
        let numSpokes = rng.next(in: 5...9)
        let maxRadius = rng.next(in: 15...30)
        
        // Draw spokes
        for i in 0..<numSpokes {
            let angle = (Double(i) / Double(numSpokes)) * 2.0 * .pi
            for r in 1...maxRadius {
                let x = center.x + Int(Double(r) * cos(angle))
                let y = center.y + Int(Double(r) * sin(angle))
                grid.setCell(at: Point(x: x, y: y), cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
            }
        }
        
        // Draw concentric rings (web connections)
        let numRings = rng.next(in: 3...6)
        for ring in 1...numRings {
            let ringRadius = (maxRadius * ring) / numRings
            for i in 0..<100 {
                let angle = (Double(i) / 100.0) * 2.0 * .pi
                let x = center.x + Int(Double(ringRadius) * cos(angle))
                let y = center.y + Int(Double(ringRadius) * sin(angle))
                // Slight chance to miss a spot (imperfect web)
                if rng.next(in: 0...100) > 10 {
                    grid.setCell(at: Point(x: x, y: y), cell: Cell(color: colorHex, characterWorld: world, intensity: 1))
                }
            }
        }
    }
}
