import Vapor

struct ASCIIRenderer: Renderer {
    // Character set representing different intensities (dark to light or vice versa)
    let chars: [Character] = [" ", ".", ":", "-", "=", "+", "*", "#", "%", "@"]
    
    func render(_ grid: Grid) throws -> Response {
        var output = ""
        
        for y in 0..<grid.height {
            for x in 0..<grid.width {
                if let cell = grid.getCell(at: Point(x: x, y: y)) {
                    // Map intensity to ASCII array bounds
                    let charIndex = min(max(cell.intensity * 2, 0), chars.count - 1)
                    output.append(chars[charIndex])
                } else {
                    output.append(" ")
                }
            }
            output.append("\n")
        }
        
        let response = Response(status: .ok, body: .init(string: output))
        response.headers.contentType = .plainText
        return response
    }
}
