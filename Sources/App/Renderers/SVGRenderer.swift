import Vapor

struct SVGRenderer: Renderer {
    let cellSize: Int = 10
    
    func render(_ grid: Grid) throws -> Response {
        let pixelWidth = grid.width * cellSize
        let pixelHeight = grid.height * cellSize
        
        var svg = """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(pixelWidth) \(pixelHeight)" width="\(pixelWidth)" height="\(pixelHeight)">
        <rect width="100%" height="100%" fill="\(grid.backgroundTheme)"/>
        
        """
        
        // Render cells
        for y in 0..<grid.height {
            for x in 0..<grid.width {
                if let cell = grid.getCell(at: Point(x: x, y: y)), let color = cell.color {
                    let rx = x * cellSize
                    let ry = y * cellSize
                    svg += "<rect x=\"\(rx)\" y=\"\(ry)\" width=\"\(cellSize)\" height=\"\(cellSize)\" fill=\"\(color)\" />\n"
                }
            }
        }
        
        svg += "</svg>"
        
        let response = Response(status: .ok, body: .init(string: svg))
        response.headers.contentType = .init(type: "image", subType: "svg+xml")
        return response
    }
}
