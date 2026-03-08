import Vapor

struct Homer: CharacterAlgorithm {
    let name = "Homer"
    let world = "20thCenturyFox"
    let country = "USA"
    let region = "Americas"
    let colorHex = "#F4A261" // Donut base
    let icingHex = "#FF99C8" // Pink Icing
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Donuts: Hollow circles with multi-colored sprinkles
        let sprinkleColors = ["#000000", "#FFFFFF", "#FF0000", "#00FF00", "#0000FF"]
        
        for _ in 0..<4 {
            let center = Point(x: rng.next(in: 10...grid.width-10), y: rng.next(in: 10...grid.height-10))
            let radius = rng.next(in: 4...8)
            
            for dy in -radius-2...radius+2 {
                for dx in -radius-2...radius+2 {
                    let dist = Double(dx*dx + dy*dy).squareRoot()
                    let p = Point(x: center.x + dx, y: center.y + dy)
                    
                    // Donut ring
                    if dist >= Double(radius) - 1.5 && dist <= Double(radius) + 1.5 {
                        let isIcing = rng.next(in: 0...10) > 3
                        var cellColor = isIcing ? icingHex : colorHex
                        
                        // Sprinkles on icing
                        if isIcing && rng.next(in: 0...10) > 8 {
                            cellColor = sprinkleColors.randomElement() ?? "#FFFFFF"
                        }
                        
                        grid.setCell(at: p, cell: Cell(color: cellColor, characterWorld: world, intensity: 3))
                    }
                }
            }
        }
    }
}
