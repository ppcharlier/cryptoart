import Vapor

struct GalleryController {
    
    func randomMixUniverse(req: Request) async throws -> Response {
        let allWorlds = Set(CharacterRegistry.all.map { $0.world })
        guard let randomWorld = allWorlds.randomElement() else { throw Abort(.notFound) }
        
        let hash = UUID().uuidString
        return req.redirect(to: "/art?world=\(randomWorld)&hash=\(hash)")
    }
    
    func randomMixMyths(req: Request) async throws -> Response {
        let myths = ["AztecMythology", "AkanMythology", "NorseMythology", "JourneyToTheWest"]
        guard let randomMyth = myths.randomElement() else { throw Abort(.notFound) }
        
        let hash = UUID().uuidString
        return req.redirect(to: "/art?world=\(randomMyth)&hash=\(hash)")
    }

    func worldGalleries(req: Request) async throws -> Response {
        let allWorlds = Set(CharacterRegistry.all.map { $0.world }).sorted()
        
        let sections = allWorlds.map { world in
            let characters = CharacterRegistry.getBySeries(world)
            let charLinks = characters.map { char in
                "<a class='char-link' href='/art?char=\(char.name)'>\(char.name)</a>"
            }.joined(separator: " ")
            
            return """
            <div class="world-section">
                <div class="world-header">
                    <span class="world-title">\(world)</span>
                    <a class="mix-button" href="/art?world=\(world)">Mix Universe ✨</a>
                </div>
                <div class="char-list">\(charLinks)</div>
            </div>
            """
        }.joined()
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Pilou CryptoArt - World Galleries</title>
            <style>
                body { background: #FDFCF0; font-family: monospace; padding: 40px; color: #333; max-width: 900px; margin: 0 auto; }
                h1 { border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 40px; text-align: center; }
                .world-section { background: white; border: 1px solid #ddd; padding: 20px; margin-bottom: 20px; box-shadow: 5px 5px 0px #ddd; }
                .world-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
                .world-title { font-size: 1.2rem; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }
                .mix-button { background: #0077B6; color: white; padding: 5px 12px; font-size: 0.8rem; text-decoration: none; border-radius: 3px; }
                .mix-button:hover { background: #023E8A; }
                .char-list { display: flex; flex-wrap: wrap; gap: 10px; }
                .char-link { background: #f8f9fa; border: 1px solid #eee; padding: 5px 10px; color: #555; text-decoration: none; font-size: 0.9rem; }
                .char-link:hover { background: #e9ecef; border-color: #0077B6; color: #0077B6; }
                .nav { margin-bottom: 30px; }
                .nav a { color: #0077B6; text-decoration: none; }
                footer { margin-top: 50px; text-align: center; font-size: 0.8rem; color: #999; }
            </style>
        </head>
        <body>
            <div class="nav"><a href="/">← Back to Home</a></div>
            <h1>World Galleries</h1>
            <div class="galleries">
                \(sections)
            </div>
            <footer>
                <p>Try <a href="/randommix/univers">Random Universe Mix</a> or <a href="/randommix/universes/myths">Random Myth Mix</a></p>
            </footer>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }
    
    func randomGallery(req: Request) async throws -> Response {
        let randomChar = CharacterRegistry.all.randomElement()!
        let randomHash = UUID().uuidString
        return req.redirect(to: "/art?hash=\(randomHash)&char=\(randomChar.name)")
    }
}
