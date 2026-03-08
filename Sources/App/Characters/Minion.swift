import Vapor

struct Minion: CharacterAlgorithm {
    let name = "Minion"
    let world = "Universal"
    let country = "USA"
    let region = "Americas"
    let colorHex = "#FFD166" // Minion Yellow
    let denimHex = "#118AB2" // Overalls Blue
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Swarm: Lots of tiny clustered blocks running around together
        var center = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
        
        for _ in 0..<30 {
            // A minion is a 2x3 block roughly
            grid.setCell(at: center, cell: Cell(color: colorHex, characterWorld: world, intensity: 2))
            grid.setCell(at: Point(x: center.x, y: center.y+1), cell: Cell(color: denimHex, characterWorld: world, intensity: 2))
            
            // Random goggle eye (silver/gray)
            if rng.next(in: 0...1) == 0 {
                grid.setCell(at: Point(x: center.x+1, y: center.y), cell: Cell(color: "#CED4DA", characterWorld: world, intensity: 4))
            }
            
            // Move the swarm slightly
            center.x += rng.next(in: -3...3)
            center.y += rng.next(in: -3...3)
        }
    }
}
