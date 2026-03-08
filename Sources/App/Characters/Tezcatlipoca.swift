import Vapor

struct Tezcatlipoca: CharacterAlgorithm {
    let name = "Tezcatlipoca"
    let world = "AztecMythology"
    let country = "Mexico"
    let region = "Americas"
    let colorHex = "#000814" // Obsidian Black
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Smoking Mirror: Absorbs light (erases) or leaves obsidian shards
        for _ in 0..<10 {
            let p = Point(x: rng.next(in: 5...grid.width-5), y: rng.next(in: 5...grid.height-5))
            if rng.next(in: 0...1) == 0 {
                // Erase (Shadow)
                grid.setCell(at: p, cell: Cell(color: nil, intensity: 0))
            } else {
                // Obsidian Shard
                grid.setCell(at: p, cell: Cell(color: colorHex, characterWorld: world, intensity: 5))
            }
        }
    }
}
