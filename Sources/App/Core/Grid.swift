import Vapor

struct Point: Hashable, Equatable, Codable {
    var x: Int
    var y: Int
}

struct Cell: Codable {
    var color: String? // Hex code, or nil for empty
    var characterWorld: String? // Trace the world series
    var intensity: Int // Used for ASCII mapping or opacity
    
    init(color: String? = nil, characterWorld: String? = nil, intensity: Int = 1) {
        self.color = color
        self.characterWorld = characterWorld
        self.intensity = intensity
    }
}

class Grid: Codable {
    let width: Int
    let height: Int
    var cells: [Point: Cell]
    
    // Background tracking
    var backgroundTheme: String = "#ffffff" // default white
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.cells = [:]
    }
    
    func setCell(at point: Point, cell: Cell) {
        if isValid(point) {
            cells[point] = cell
        }
    }
    
    func getCell(at point: Point) -> Cell? {
        return cells[point]
    }
    
    func isValid(_ point: Point) -> Bool {
        return point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }
}
