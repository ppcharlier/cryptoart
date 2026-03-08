import Vapor
import Logging

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        let localApp = app
        defer { Task { try? await localApp.asyncShutdown() } }
        
        try configure(app)
        try await app.execute()
    }
}
