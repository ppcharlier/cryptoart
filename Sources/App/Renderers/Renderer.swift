import Vapor

protocol Renderer {
    func render(_ grid: Grid) throws -> Response
}
