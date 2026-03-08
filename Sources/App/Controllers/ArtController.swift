import Vapor
import Crypto

struct ArtQuery: Content {
    var hash: String?
    var char: String?
    var world: String? 
    var format: String?
    var width: Int?
    var height: Int?
    var recipe: String? 
}

struct ArtController {
    
    private func sha512(_ input: String) -> String {
        let digest = SHA512.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func generateDNA(char: String, world: String?, w: Int, h: Int) -> String {
        let input = "\(char)-\(world ?? "none")-\(w)x\(h)"
        return sha512(input)
    }

    private func buildSeed(recipe: String?, base: String) -> String {
        guard let recipe = recipe, !recipe.isEmpty else { return base }
        var current = base
        let steps = recipe.lowercased().split(separator: ",")
        for step in steps {
            let s = step.trimmingCharacters(in: .whitespaces)
            switch s {
            case "sha256": current = sha256(current)
            case "sha512": current = sha512(current)
            case "uuid": current = sha256(current + UUID().uuidString) 
            default: break
            }
        }
        return current
    }

    // Shared UI Components
    private func composerHTML(currentRecipe: String?, charName: String) -> String {
        let recipe = currentRecipe ?? ""
        return """
        <div class="composer">
            <div class="composer-title">CRYPTOGRAPHIC COMPOSER</div>
            <div class="ingredients">
                <button onclick="addIngredient('sha256')">+ SHA256</button>
                <button onclick="addIngredient('sha512')">+ SHA512</button>
                <button onclick="addIngredient('uuid')">+ UUID</button>
            </div>
            <div id="recipe-display" class="recipe-display">
                <!-- Chips will be injected here -->
            </div>
            <button id="mint-button" class="mint-button" onclick="mint()">✨ MINT NEW ART</button>
        </div>

        <script>
            let currentRecipe = "\(recipe)".split(',').filter(s => s.length > 0);
            
            function renderRecipe() {
                const display = document.getElementById('recipe-display');
                display.innerHTML = '';
                currentRecipe.forEach((ing, index) => {
                    const chip = document.createElement('div');
                    chip.className = 'chip';
                    chip.innerHTML = ing.toUpperCase() + ' <span onclick="removeIngredient(' + index + ')">&times;</span>';
                    display.appendChild(chip);
                });
                document.getElementById('mint-button').style.display = currentRecipe.length > 0 ? 'inline-block' : 'none';
            }

            function addIngredient(type) {
                currentRecipe.push(type);
                renderRecipe();
            }

            function removeIngredient(index) {
                currentRecipe.splice(index, 1);
                renderRecipe();
            }

            function mint() {
                const recipeStr = currentRecipe.join(',');
                const url = new URL(window.location.href);
                url.searchParams.set('recipe', recipeStr);
                url.searchParams.delete('hash'); // Fresh hash for new mint
                window.location.href = url.toString();
            }

            renderRecipe();
        </script>
        """
    }

    private let commonStyles = """
        body { background: #FDFCF0; font-family: monospace; display: flex; flex-direction: column; align-items: center; min-height: 100vh; margin: 0; padding: 20px; color: #333; }
        .canvas { box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid #ddd; background: white; margin-bottom: 30px; max-width: 90vw; }
        .info { text-align: center; margin-bottom: 40px; max-width: 900px; width: 100%; }
        .seed-box { background: #eee; padding: 15px; border-radius: 5px; text-align: left; font-size: 0.7rem; margin-bottom: 20px; border-left: 4px solid #d63384; }
        .seed-label { font-weight: bold; color: #333; display: block; margin-bottom: 5px; }
        .seed-value { color: #d63384; word-break: break-all; }
        
        .composer { background: #fff; border: 2px solid #333; padding: 20px; border-radius: 8px; width: 100%; max-width: 600px; margin: 20px 0; box-shadow: 8px 8px 0px #333; }
        .composer-title { font-weight: bold; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .ingredients { display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap; }
        .ingredients button { background: #333; color: white; border: none; padding: 8px 15px; cursor: pointer; font-family: monospace; font-size: 0.8rem; }
        .ingredients button:hover { background: #000; transform: translateY(-2px); }
        .recipe-display { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; min-height: 40px; align-items: center; }
        .chip { background: #d63384; color: white; padding: 5px 12px; border-radius: 20px; font-size: 0.7rem; display: flex; align-items: center; gap: 8px; }
        .chip span { cursor: pointer; font-weight: bold; font-size: 1rem; }
        .mint-button { background: #0077B6; color: white; border: none; padding: 12px 25px; cursor: pointer; font-weight: bold; font-family: monospace; }
        .mint-button:hover { background: #023E8A; }
        
        .related { width: 100%; max-width: 900px; border-top: 1px solid #ddd; padding-top: 20px; }
        .related-grid { display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; }
        .related-item { border: 1px solid #eee; background: white; padding: 5px; transition: transform 0.1s; }
        .related-item:hover { transform: scale(1.1); }
        a { color: #0077B6; text-decoration: none; }
    """
    
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
            <title>Pilou CryptoArt</title>
            <style>\(commonStyles)</style>
        </head>
        <body>
            <div class="canvas">\(svgString)</div>
            <div class="info">
                <h2>\(randomChar.name) (\(randomChar.world))</h2>
                <div class="seed-box">
                    <span class="seed-label">ALGORITHM DNA (SHA512):</span>
                    <span class="seed-value">\(dna)</span>
                    <br><br>
                    <span class="seed-label">UNIQUE MINT SEED (UUID/HASH):</span>
                    <span class="seed-value">\(randomHash)</span>
                </div>
                \(composerHTML(currentRecipe: nil, charName: randomChar.name))
                <p style="margin-top:20px;">
                    <a href="/world/galleries">Galleries</a> | 
                    <a href="/randomgallery">New Random</a> | 
                    <a href="/past">Archives</a> |
                    <a href="/pistory">PPP Pistory</a>
                </p>
            </div>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
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
            <title>Pilou CryptoArt - Archives</title>
            <style>
                \(commonStyles)
                .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; width: 100%; }
                .item { border: 1px solid #ddd; background: white; padding: 10px; transition: transform 0.2s; }
                .item:hover { transform: scale(1.05); z-index: 10; box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
                .seed-label { font-size: 0.8rem; font-weight: bold; color: #333; margin-top: 10px; text-align: center; }
                .seed-hash { font-size: 0.6rem; color: #999; text-align: center; }
                img { width: 100%; height: auto; display: block; background: #fafafa; }
            </style>
        </head>
        <body>
            <div class="nav"><a href="/">← Back Home</a></div>
            <h1>The Archives of Chaos</h1>
            <div class="grid">\(list.isEmpty ? "<p>No art archived yet.</p>" : list)</div>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    func pistory(req: Request) async throws -> Response {
        let items = StorageService.listAllMetadata().filter { $0["character"]?.lowercased() == "ppp" }
        let list = items.map { meta in
            let seed = meta["seed"] ?? ""
            let url = "/art?hash=\(seed)&char=ppp"
            return """
            <div class="item">
                <a href="\(url)">
                    <img src="\(url)&raw=true" width="200" height="120" />
                    <div class="seed-label">PPP Principal</div>
                    <div class="seed-hash">\(seed.prefix(8))...</div>
                </a>
            </div>
            """
        }.joined()
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Pilou CryptoArt - Pistory</title>
            <style>
                \(commonStyles)
                .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; width: 100%; }
                .item { border: 1px solid #ddd; background: white; padding: 10px; transition: transform 0.2s; }
                .item:hover { transform: scale(1.05); z-index: 10; box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
                .seed-label { font-size: 0.8rem; font-weight: bold; color: #333; margin-top: 10px; text-align: center; }
                .seed-hash { font-size: 0.6rem; color: #999; text-align: center; }
                img { width: 100%; height: auto; display: block; background: #fafafa; }
            </style>
        </head>
        <body>
            <div class="nav"><a href="/">← Back Home</a></div>
            <h1>The Pistory of PPP</h1>
            <div class="grid">\(list.isEmpty ? "<p>No PPP art archived yet.</p>" : list)</div>
        </body>
        </html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    func generateHierarchicalArt(req: Request) async throws -> Response {
        let character = req.parameters.get("character") ?? ""
        let query = try req.query.decode(ArtQuery.self)
        var w = query.width ?? 60
        var h = query.height ?? 60
        if character.lowercased() == "parcival", let recipe = query.recipe {
            let keyCount = recipe.split(separator: ",").count
            w = max(60, keyCount * 30); h = max(60, keyCount * 30)
        }
        if character.lowercased() == "ppp" { w = 100; h = 60 }
        let finalSeed = self.buildSeed(recipe: query.recipe, base: query.hash ?? UUID().uuidString)
        return try await self.runGeneration(req: req, hash: finalSeed, charName: character, worldName: query.world, format: query.format?.lowercased() ?? "svg", w: w, h: h)
    }

    func generateArt(req: Request) async throws -> Response {
        let query = try req.query.decode(ArtQuery.self)
        let charName = query.char ?? "all"
        var w = query.width ?? 50
        var h = query.height ?? 50
        if charName.lowercased() == "parcival", let recipe = query.recipe {
            let keyCount = recipe.split(separator: ",").count
            w = max(50, keyCount * 30); h = max(50, keyCount * 30)
        }
        if charName.lowercased() == "ppp" { w = 100; h = 60 }
        let finalSeed = self.buildSeed(recipe: query.recipe, base: query.hash ?? UUID().uuidString)
        return try await self.runGeneration(req: req, hash: finalSeed, charName: charName, worldName: query.world, format: query.format?.lowercased() ?? "svg", w: w, h: h)
    }
    
    private func runGeneration(req: Request, hash: String, charName: String, worldName: String? = nil, format: String, w: Int, h: Int) async throws -> Response {
        let maxGridSize = 500
        guard w <= maxGridSize, h <= maxGridSize, w > 0, h > 0 else { throw Abort(.badRequest) }
        let grid = Grid(width: w, height: h); grid.backgroundTheme = "#FDFCF0" 
        var rng = SeededGenerator(hashString: hash)
        if let world = worldName {
            let worldChars = CharacterRegistry.getBySeries(world)
            for algo in worldChars { algo.apply(to: grid, using: &rng) }
        } else if charName == "all" {
            for algo in CharacterRegistry.all { algo.apply(to: grid, using: &rng) }
        } else if let algo = CharacterRegistry.get(name: charName) {
            algo.apply(to: grid, using: &rng)
        } else { throw Abort(.notFound) }
        let renderer: Renderer = (format == "ascii") ? ASCIIRenderer() : (format == "json" ? JSONRenderer() : SVGRenderer())
        let response = try renderer.render(grid)
        do {
            try StorageService.saveMetadata(seed: hash, character: charName, world: worldName)
            if let bodyBuffer = response.body.buffer { try StorageService.save(data: Data(buffer: bodyBuffer), filename: hash, format: format) }
        } catch { print("Persistence error: \(error)") }

        if format == "svg" && req.query[String.self, at: "raw"] == nil {
            let svgString = String(buffer: response.body.buffer!)
            let relatedSeeds = StorageService.getRelatedSeeds(character: charName).filter { $0 != hash }.reversed().prefix(8)
            let relatedGallery = relatedSeeds.map { seed in
                "<div class='related-item'><a href='/art?hash=\(seed)&char=\(charName)'><img src='/art?hash=\(seed)&char=\(charName)&raw=true' width='100' height='100' /></a></div>"
            }.joined()
            let dna = self.generateDNA(char: charName, world: worldName, w: w, h: h)
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Pilou CryptoArt - \(charName)</title>
                <style>\(commonStyles)</style>
            </head>
            <body>
                <div class="canvas">\(svgString)</div>
                <div class="info">
                    <h2>\(charName) (\(worldName ?? "Original"))</h2>
                    <div class="seed-box">
                        <span class="seed-label">ALGORITHM DNA (SHA512):</span>
                        <span class="seed-value">\(dna)</span>
                        <br><br>
                        <span class="seed-label">FINAL COMPOSITE SEED:</span>
                        <span class="seed-value">\(hash)</span>
                    </div>
                    \(composerHTML(currentRecipe: req.query["recipe"], charName: charName))
                    <p style="margin-top:20px;"><a href="/past">Archives</a> | <a href="/pistory">PPP Pistory</a> | <a href="/randomgallery">New Random</a> | <a href="/">Home</a></p>
                </div>
                \(relatedGallery.isEmpty ? "" : "<div class='related'><h3>History for \(charName):</h3><div class='related-grid'>\(relatedGallery)</div></div>")
            </body>
            </html>
            """
            return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
        }
        response.headers.add(name: "X-CryptoArt-Seed", value: hash)
        return response
    }
}
