import Vapor

struct Shrek: CharacterAlgorithm {
    let name = "Shrek"
    let world = "Dreamworks"
    let country = "USA"
    let region = "Americas"
    let colorHex = "#588157" // Ogre Green
    let mudHex = "#5E503F" // Swamp Mud
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Swamp Mud Splatters: Localized irregular blobs
        for _ in 0..<6 {
            let center = Point(x: rng.next(in: 0...grid.width-1), y: rng.next(in: 0...grid.height-1))
            let blobSize = rng.next(in: 3...7)
            
            for dy in -blobSize...blobSize {
                for dx in -blobSize...blobSize {
                    // Circle-ish blob
                    if dx*dx + dy*dy <= blobSize*blobSize {
                        let p = Point(x: center.x + dx, y: center.y + dy)
                        // Mostly green with mud spots
                        let color = rng.next(in: 0...10) > 7 ? mudHex : colorHex
                        if rng.next(in: 0...100) > 20 { // Imperfect blob
                            grid.setCell(at: p, cell: Cell(color: color, characterWorld: world, intensity: 3))
                        }
                    }
                }
            }
        }
    }
}
