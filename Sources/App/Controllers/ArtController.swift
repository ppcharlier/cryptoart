import Vapor
import Crypto

struct ArtQuery: Content {
    var hash: String?
    var char: String?
    var world: String? 
    var format: String?
    var width: Int?
    var height: Int?
    var mode: String? // uuid, dna, combined
}

struct ArtController {
    
    // Helper to generate SHA512 DNA of an algorithm configuration
    private func generateDNA(char: String, world: String?, w: Int, h: Int) -> String {
        let input = "\(char)-\(world ?? "none")-\(w)x\(h)"
        let digest = SHA512.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func index(req: Request) async throws -> Response {
        let randomHash = UUID().uuidString
        let randomChar = CharacterRegistry.all.randomElement()!
        
        let grid = Grid(width: 80, height: 80)
        grid.backgroundTheme = "#FDFCF0"
        var rng = SeededGenerator(hashString: randomHash)
        randomChar.apply(to: grid, using: &rng)
        
        let svgResponse = try SVGRenderer().render(grid)
        let svgString = String(buffer: svgResponse.body.buffer!)
        let dna = self.generateDNA(char: randomChar.name, world: randomChar.world, w: 80, h: 80)

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Pilou CryptoArt - \(randomChar.name)</title>
            <style>
                body { background: #FDFCF0; font-family: monospace; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 20px;}
                .canvas { box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid #ddd; max-width: 90vw; max-height: 70vh; background: white; }
                footer { margin-top: 30px; color: #666; font-size: 0.8rem; text-align: center; max-width: 800px; }
                .seed-box { background: #eee; padding: 15px; border-radius: 5px; text-align: left; font-size: 0.7rem; margin-top: 20px; border-left: 4px solid #d63384; }
                .seed-label { font-weight: bold; color: #333; display: block; margin-bottom: 5px; }
                .seed-value { color: #d63384; word-break: break-all; }
                a { color: #0077B6; text-decoration: none; }
            </style>
        </head>
        <body>
            <div class="canvas">\(svgString)</div>
            <footer>
                <p>Character: <strong>\(randomChar.name)</strong> (\(randomChar.world))</p>
                
                <div class="seed-box">
                    <span class="seed-label">ALGORITHM DNA (SHA512):</span>
                    <span class="seed-value">\(dna)</span>
                    <br><br>
                    <span class="seed-label">UNIQUE MINT SEED (UUID/HASH):</span>
                    <span class="seed-value">\(randomHash)</span>
                </div>

                <p style="margin-top:20px;">
                    <a href="/world/galleries">Galleries</a> | 
                    <a href="/randomgallery">New Random</a> | 
                    <a href="/past">Archives</a>
                </p>
            </footer>
        </body>
        </html>
        """
        
        let response = Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
        response.headers.add(name: "X-CryptoArt-Seed", value: randomHash)
        return response
    }

    func pastArt(req: Request) async throws -> Response {
        let items = StorageService.listAllMetadata()
        
        let list = items.map { meta in
            let seed = meta["seed"] ?? ""
            let char = meta["character"] ?? "all"
            let world = meta["world"] ?? ""
            var url = "/art?hash=\(seed)&char=\(char)"
            if !world.isEmpty && world != "all" { url += "&world=\(world)" }
            
            return """
            <div class="item">
                <a href="\(url)">
                    <img src="\(url)&raw=true" width="200" height="200" />
                    <div class="seed-label">\(char) (\(world.prefix(12))...)</div>
                    <div class="seed-hash">\(seed.prefix(8))...</div>
                </a>
            </div>
            """
        }.joined()
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Pilou CryptoArt - The Archives</title>
            <style>
                body { background: #FDFCF0; font-family: monospace; padding: 40px; }
                h1 { text-align: center; color: #333; }
                .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
                .item { border: 1px solid #ddd; background: white; padding: 10px; transition: transform 0.2s; }
                .item:hover { transform: scale(1.05); z-index: 10; box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
                .seed-label { font-size: 0.8rem; font-weight: bold; color: #333; margin-top: 10px; text-align: center; }
                .seed-hash { font-size: 0.6rem; color: #999; text-align: center; }
                img { width: 100%; height: auto; display: block; background: #fafafa; }
                .nav { margin-bottom: 20px; text-align: center; }
                a { color: #0077B6; text-decoration: none; }
            </style>
        </head>
        <body>
            <div class="nav"><a href="/">← Back to Live Generation</a></div>
            <h1>The Archives of Chaos</h1>
            <div class="grid">\(list.isEmpty ? "<p>No art archived yet.</p>" : list)</div>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    func generateHierarchicalArt(req: Request) async throws -> Response {
        let character = req.parameters.get("character") ?? ""
        let query = try req.query.decode(ArtQuery.self)
        
        let w = query.width ?? 60
        let h = query.height ?? 60
        let worldName = query.world
        let dna = self.generateDNA(char: character, world: worldName, w: w, h: h)
        let uuid = query.hash ?? UUID().uuidString
        
        let finalSeed: String
        switch query.mode?.lowercased() {
        case "dna": finalSeed = dna
        case "combined": finalSeed = "\(dna)-\(uuid)"
        default: finalSeed = uuid
        }

        return try await self.runGeneration(
            req: req,
            hash: finalSeed,
            charName: character,
            worldName: worldName,
            format: query.format?.lowercased() ?? "svg",
            w: w,
            h: h
        )
    }

    func generateArt(req: Request) async throws -> Response {
        let query = try req.query.decode(ArtQuery.self)
        let charName = query.char ?? "all"
        let worldName = query.world
        let w = query.width ?? 50
        let h = query.height ?? 50
        let dna = self.generateDNA(char: charName, world: worldName, w: w, h: h)
        let uuid = query.hash ?? UUID().uuidString
        
        let finalSeed: String
        switch query.mode?.lowercased() {
        case "dna": finalSeed = dna
        case "combined": finalSeed = "\(dna)-\(uuid)"
        default: finalSeed = uuid
        }
        
        return try await self.runGeneration(
            req: req,
            hash: finalSeed,
            charName: charName,
            worldName: worldName,
            format: query.format?.lowercased() ?? "svg",
            w: w,
            h: h
        )
    }
    
    private func runGeneration(req: Request, hash: String, charName: String, worldName: String? = nil, format: String, w: Int, h: Int) async throws -> Response {
        let maxGridSize = 500
        guard w <= maxGridSize, h <= maxGridSize, w > 0, h > 0 else {
            throw Abort(.badRequest, reason: "Invalid grid size.")
        }
        
        let grid = Grid(width: w, height: h)
        grid.backgroundTheme = "#FDFCF0" 
        var rng = SeededGenerator(hashString: hash)
        
        if let world = worldName {
            let worldChars = CharacterRegistry.getBySeries(world)
            for algo in worldChars { algo.apply(to: grid, using: &rng) }
        } else if charName == "all" {
            for algo in CharacterRegistry.all { algo.apply(to: grid, using: &rng) }
        } else if let algo = CharacterRegistry.get(name: charName) {
            algo.apply(to: grid, using: &rng)
        } else {
            throw Abort(.notFound)
        }
        
        let renderer: Renderer
        if format == "ascii" {
            renderer = ASCIIRenderer()
        } else if format == "json" {
            renderer = JSONRenderer()
        } else {
            renderer = SVGRenderer()
        }
        let response = try renderer.render(grid)
        
        // SAVE PERSISTENCE
        do {
            try StorageService.saveMetadata(seed: hash, character: charName, world: worldName)
            if let bodyBuffer = response.body.buffer {
                try StorageService.save(data: Data(buffer: bodyBuffer), filename: hash, format: format)
            }
        } catch { print("Persistence error: \(error)") }

        // Return HTML by default
        if format == "svg" && req.query[String.self, at: "raw"] == nil {
            let svgString = String(buffer: response.body.buffer!)
            let relatedSeeds = StorageService.getRelatedSeeds(character: charName)
                .filter { $0 != hash }.reversed().prefix(8)
            
            let relatedGallery = relatedSeeds.map { seed in
                """
                <div class="related-item">
                    <a href="/art?hash=\(seed)&char=\(charName)">
                        <img src="/art?hash=\(seed)&char=\(charName)&raw=true" width="100" height="100" />
                    </a>
                </div>
                """
            }.joined()

            let dna = self.generateDNA(char: charName, world: worldName, w: w, h: h)

            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Pilou CryptoArt - \(charName)</title>
                <style>
                    body { background: #FDFCF0; font-family: monospace; display: flex; flex-direction: column; align-items: center; min-height: 100vh; margin: 0; padding: 20px; }
                    .canvas { box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid #ddd; background: white; margin-bottom: 30px; }
                    .info { text-align: center; margin-bottom: 40px; max-width: 900px; }
                    .seed-box { background: #eee; padding: 15px; border-radius: 5px; text-align: left; font-size: 0.7rem; margin-top: 20px; border-left: 4px solid #d63384; }
                    .seed-label { font-weight: bold; color: #333; display: block; margin-bottom: 5px; }
                    .seed-value { color: #d63384; word-break: break-all; }
                    .related { width: 100%; max-width: 900px; border-top: 1px solid #ddd; padding-top: 20px; }
                    .related-grid { display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; }
                    .related-item { border: 1px solid #eee; background: white; padding: 5px; transition: transform 0.1s; }
                    .related-item:hover { transform: scale(1.1); }
                    a { color: #0077B6; text-decoration: none; }
                </style>
            </head>
            <body>
                <div class="canvas">\(svgString)</div>
                <div class="info">
                    <h2>\(charName) (\(worldName ?? "Original"))</h2>
                    <div class="seed-box">
                        <span class="seed-label">ALGORITHM DNA (SHA512):</span>
                        <span class="seed-value">\(dna)</span>
                        <br><br>
                        <span class="seed-label">UNIQUE MINT SEED (FINAL):</span>
                        <span class="seed-value">\(hash)</span>
                    </div>
                    <p style="margin-top:20px;"><a href="/past">Archives</a> | <a href="/randomgallery">New Random</a> | <a href="/">Home</a></p>
                </div>
                \(relatedGallery.isEmpty ? "" : """
                <div class="related">
                    <h3>History for \(charName):</h3>
                    <div class="related-grid">\(relatedGallery)</div>
                </div>
                """)
            </body>
            </html>
            """
            return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
        }
        response.headers.add(name: "X-CryptoArt-Seed", value: hash)
        return response
    }
}
