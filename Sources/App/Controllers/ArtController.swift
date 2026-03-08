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
    var scale: Int? 
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
            default: current = sha256(current + s) 
            }
        }
        return current
    }

    private func composerHTML(currentRecipe: String?, charName: String) -> String {
        let recipe = currentRecipe ?? ""
        return """
        <div class="composer">
            <div class="composer-title">UNIVERSAL EXPANSION COMPOSER</div>
            
            <div class="input-group">
                <label>Magic Phrase (Space separated words become keys):</label>
                <input type="text" id="phrase-input" placeholder="Type your story here..." oninput="parsePhrase()">
            </div>

            <div class="ingredients">
                <button onclick="addIngredient('sha256')">+ SHA256</button>
                <button onclick="addIngredient('sha512')">+ SHA512</button>
                <button onclick="addIngredient('uuid')">+ UUID</button>
            </div>

            <div id="recipe-display" class="recipe-display"></div>
            
            <div class="scale-selector">
                <label>Universe Scale:</label>
                <select id="scale-input">
                    <option value="64">64x64 (Classic)</option>
                    <option value="128">128x128 (Expanded)</option>
                    <option value="256">256x256 (Galactic)</option>
                    <option value="512">512x512 (Universal)</option>
                </select>
            </div>

            <button id="mint-button" class="mint-button" onclick="mint()">🚀 EXPAND & MINT</button>
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
            }

            function parsePhrase() {
                const input = document.getElementById('phrase-input').value;
                if (!input) return;
                const words = input.trim().split(/\\s+/);
                words.forEach(w => {
                    if (w.length > 2 && !currentRecipe.includes(w)) {
                        currentRecipe.push(w);
                    }
                });
                renderRecipe();
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
                const scale = document.getElementById('scale-input').value;
                const url = new URL(window.location.href);
                url.searchParams.set('recipe', recipeStr);
                url.searchParams.set('width', scale);
                url.searchParams.set('height', scale);
                url.searchParams.delete('hash'); 
                window.location.href = url.toString();
            }

            renderRecipe();
        </script>
        """
    }

    private let commonStyles = """
        body { background: #1a1a1a; font-family: 'Courier New', monospace; display: flex; flex-direction: column; align-items: center; min-height: 100vh; margin: 0; padding: 20px; color: #eee; }
        .canvas-container { display: flex; flex-direction: column; align-items: center; gap: 20px; width: 100%; }
        .canvas { box-shadow: 0 0 50px rgba(0,255,255,0.1); border: 1px solid #444; background: #000; max-width: 90vw; }
        .ascii-art { background: #000; color: #0f0; padding: 20px; font-size: 6px; line-height: 6px; white-space: pre; border: 1px solid #333; overflow: auto; max-width: 90vw; max-height: 400px; width: 100%; text-align: center; }
        
        .info { text-align: center; margin-bottom: 40px; max-width: 900px; width: 100%; }
        .seed-box { background: #222; padding: 15px; border-radius: 5px; text-align: left; font-size: 0.7rem; margin-top: 20px; border-left: 4px solid #00f2ff; color: #aaa; }
        .seed-label { font-weight: bold; color: #00f2ff; display: block; margin-bottom: 5px; }
        .seed-value { color: #fff; word-break: break-all; }
        
        .composer { background: #222; border: 1px solid #444; padding: 25px; border-radius: 8px; width: 100%; max-width: 700px; margin: 20px 0; }
        .composer-title { color: #00f2ff; font-weight: bold; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 2px; }
        
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { display: block; font-size: 0.8rem; margin-bottom: 8px; color: #888; }
        .input-group input { width: 100%; background: #111; border: 1px solid #444; padding: 12px; color: #fff; font-family: monospace; box-sizing: border-box; }
        
        .ingredients { display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap; }
        .ingredients button { background: #444; color: white; border: none; padding: 8px 15px; cursor: pointer; font-family: monospace; font-size: 0.7rem; }
        .ingredients button:hover { background: #666; }
        
        .scale-selector { margin-bottom: 20px; text-align: left; }
        .scale-selector label { font-size: 0.8rem; color: #888; margin-right: 10px; }
        .scale-selector select { background: #111; color: #fff; border: 1px solid #444; padding: 5px; font-family: monospace; }

        .recipe-display { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; min-height: 40px; align-items: center; background: #111; padding: 10px; border-radius: 4px; }
        .chip { background: #00f2ff; color: #000; padding: 4px 10px; border-radius: 3px; font-size: 0.7rem; display: flex; align-items: center; gap: 8px; font-weight: bold; }
        .chip span { cursor: pointer; font-size: 1.1rem; }
        
        .mint-button { background: #00f2ff; color: #000; border: none; padding: 15px 40px; cursor: pointer; font-weight: bold; font-family: monospace; width: 100%; font-size: 1rem; letter-spacing: 2px; }
        .mint-button:hover { background: #fff; }
        
        .related-grid { display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; margin-top: 20px; }
        .related-item { border: 1px solid #333; background: #000; padding: 5px; }
        a { color: #00f2ff; text-decoration: none; }
        h2 { color: #fff; margin-bottom: 5px; }
    """
    
    func index(req: Request) async throws -> Response {
        let randomHash = UUID().uuidString
        let randomChar = CharacterRegistry.all.randomElement()!
        return try await self.runGeneration(req: req, hash: randomHash, charName: randomChar.name, format: "svg", w: 64, h: 64)
    }

    func pastArt(req: Request) async throws -> Response {
        let items = StorageService.listAllMetadata()
        let list = items.map { meta in
            let seed = meta["seed"] ?? ""
            let char = meta["character"] ?? "all"
            let url = "/art?hash=\(seed)&char=\(char)"
            return "<div class='item'><a href='\(url)'><img src='\(url)&raw=true' width='150' /><div class='label'>\(char)</div></a></div>"
        }.joined()
        let html = """
        <!DOCTYPE html><html><head><title>Archives</title><style>\(commonStyles) .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 20px; width: 100%; } .item { background: #222; padding: 10px; text-align: center; } .label { font-size: 0.7rem; margin-top: 5px; }</style></head>
        <body><div class="nav"><a href="/">← HOME</a></div><h1>THE ARCHIVES</h1><div class="grid">\(list)</div></body></html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    func pistory(req: Request) async throws -> Response {
        let items = StorageService.listAllMetadata().filter { $0["character"]?.lowercased() == "ppp" }
        let list = items.map { meta in
            let seed = meta["seed"] ?? ""
            let url = "/art?hash=\(seed)&char=ppp"
            return "<div class='item'><a href='\(url)'><img src='\(url)&raw=true' width='200' /><div class='label'>PPP</div></a></div>"
        }.joined()
        let html = """
        <!DOCTYPE html><html><head><title>PPP Pistory</title><style>\(commonStyles) .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; width: 100%; } .item { background: #222; padding: 10px; text-align: center; }</style></head>
        <body><div class="nav"><a href="/">← HOME</a></div><h1>THE PISTORY</h1><div class="grid">\(list)</div></body></html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }

    func generateHierarchicalArt(req: Request) async throws -> Response {
        let character = req.parameters.get("character") ?? ""
        let query = try req.query.decode(ArtQuery.self)
        var w = query.width ?? 64
        var h = query.height ?? 64
        if character.lowercased() == "parcival", let recipe = query.recipe {
            let keyCount = recipe.split(separator: ",").count
            w = max(64, keyCount * 32); h = max(64, keyCount * 32)
        }
        if character.lowercased() == "ppp" { w = 128; h = 64 }
        let finalSeed = self.buildSeed(recipe: query.recipe, base: query.hash ?? UUID().uuidString)
        return try await self.runGeneration(req: req, hash: finalSeed, charName: character, worldName: query.world, format: query.format?.lowercased() ?? "svg", w: w, h: h)
    }

    func generateArt(req: Request) async throws -> Response {
        let query = try req.query.decode(ArtQuery.self)
        let charName = query.char ?? "all"
        var w = query.width ?? 64
        var h = query.height ?? 64
        if charName.lowercased() == "parcival", let recipe = query.recipe {
            let keyCount = recipe.split(separator: ",").count
            w = max(64, keyCount * 32); h = max(64, keyCount * 32)
        }
        if charName.lowercased() == "ppp" { w = 128; h = 64 }
        let finalSeed = self.buildSeed(recipe: query.recipe, base: query.hash ?? UUID().uuidString)
        return try await self.runGeneration(req: req, hash: finalSeed, charName: charName, worldName: query.world, format: query.format?.lowercased() ?? "svg", w: w, h: h)
    }
    
    private func runGeneration(req: Request, hash: String, charName: String, worldName: String? = nil, format: String, w: Int, h: Int) async throws -> Response {
        let maxGridSize = 512
        let grid = Grid(width: min(w, maxGridSize), height: min(h, maxGridSize))
        grid.backgroundTheme = "#000000" 
        var rng = SeededGenerator(hashString: hash)
        
        if let world = worldName {
            for algo in CharacterRegistry.getBySeries(world) { algo.apply(to: grid, using: &rng) }
        } else if charName == "all" {
            for algo in CharacterRegistry.all { algo.apply(to: grid, using: &rng) }
        } else if let algo = CharacterRegistry.get(name: charName) {
            algo.apply(to: grid, using: &rng)
        } else { throw Abort(.notFound) }
        
        do {
            try StorageService.saveMetadata(seed: hash, character: charName, world: worldName)
            let svgData = try SVGRenderer().render(grid).body.buffer!
            try StorageService.save(data: Data(buffer: svgData), filename: hash, format: "svg")
        } catch { print(error) }

        if req.query[String.self, at: "raw"] != nil {
            if format == "ascii" { return try ASCIIRenderer().render(grid) }
            else { return try SVGRenderer().render(grid) }
        }

        let svgString = String(buffer: try SVGRenderer().render(grid).body.buffer!)
        let asciiString = String(buffer: try ASCIIRenderer().render(grid).body.buffer!)
        let dna = self.generateDNA(char: charName, world: worldName, w: w, h: h)

        let html = """
        <!DOCTYPE html><html><head><title>Pilou CryptoArt</title><style>\(commonStyles)</style></head>
        <body><div class="canvas-container"><div class="canvas">\(svgString)</div><div class="ascii-art">\(asciiString)</div></div>
        <div class="info"><h2>\(charName) (\(worldName ?? "Original"))</h2>
        <div class="seed-box"><span class="seed-label">ALGORITHM DNA:</span><span class="seed-value">\(dna)</span><br><br>
        <span class="seed-label">FINAL COMPOSITE SEED:</span><span class="seed-value">\(hash)</span></div>
        \(composerHTML(currentRecipe: req.query["recipe"], charName: charName))
        <p style="margin-top:20px;"><a href="/world/galleries">Galleries</a> | <a href="/past">Archives</a> | <a href="/pistory">Pistory</a></p>
        </div></body></html>
        """
        return Response(status: .ok, headers: ["Content-Type": "text/html"], body: .init(string: html))
    }
}
