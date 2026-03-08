import Vapor

struct Loki: CharacterAlgorithm {
    let name = "Loki"
    let world = "NorseMythology"
    let country = "Norway"
    let region = "Europe"
    let colorHex = "#386641" // Deceptive Green
    
    func apply(to grid: Grid, using rng: inout SeededGenerator) {
        // Illusions: Mirrors existing paths with a color shift
        let existingCells = grid.cells
        for (point, cell) in existingCells {
            if rng.next(in: 0...100) < 20 {
                // Mirror the point
                let mirrored = Point(x: grid.width - point.x, y: point.y)
                grid.setCell(at: mirrored, cell: Cell(color: colorHex, characterWorld: world, intensity: cell.intensity))
            }
        }
    }
}
