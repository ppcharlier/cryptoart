import Vapor

struct JSONRenderer: Renderer {
    func render(_ grid: Grid) throws -> Response {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(grid)
        let response = Response(status: .ok, body: .init(data: data))
        response.headers.contentType = .json
        return response
    }
}
