import Vapor

struct StorageService {
    static let basePath = Environment.get("DATA_PATH") ?? "./data"
    
    static func save(content: String, filename: String, format: String) throws {
        let fileManager = FileManager.default
        let folderPath = "\(basePath)/\(format)"
        
        // Ensure directory exists
        if !fileManager.fileExists(atPath: folderPath) {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
        }
        
        let filePath = "\(folderPath)/\(filename).\(format)"
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        print("Art saved to disk: \(filePath)")
    }
    
    static func save(data: Data, filename: String, format: String) throws {
        let fileManager = FileManager.default
        let folderPath = "\(basePath)/\(format)"
        
        if !fileManager.fileExists(atPath: folderPath) {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
        }
        
        let filePath = "\(folderPath)/\(filename).\(format)"
        try data.write(to: URL(fileURLWithPath: filePath))
        print("Data saved to disk: \(filePath)")
    }
    
    static func saveMetadata(seed: String, character: String, world: String?) throws {
        let fileManager = FileManager.default
        let folderPath = "\(basePath)/metadata"
        if !fileManager.fileExists(atPath: folderPath) {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
        }
        
        let metadata: [String: String] = [
            "seed": seed,
            "character": character,
            "world": world ?? "all"
        ]
        let data = try JSONSerialization.data(withJSONObject: metadata)
        try data.write(to: URL(fileURLWithPath: "\(folderPath)/\(seed).json"))
    }
    
    static func getRelatedSeeds(character: String) -> [String] {
        let folderPath = "\(basePath)/metadata"
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: folderPath) else { return [] }
        
        var related: [String] = []
        for file in files where file.hasSuffix(".json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: "\(folderPath)/\(file)")),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               json["character"] == character {
                related.append(json["seed"] ?? "")
            }
        }
        return related
    }

    static func listAllMetadata() -> [[String: String]] {
        let folderPath = "\(basePath)/metadata"
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: folderPath) else { return [] }
        
        var all: [[String: String]] = []
        for file in files where file.hasSuffix(".json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: "\(folderPath)/\(file)")),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                all.append(json)
            }
        }
        // Sort by seed/filename to keep some order, or by date if we had it
        return all.sorted { ($0["seed"] ?? "") > ($1["seed"] ?? "") }
    }

    static func listAll(format: String) -> [String] {
        let folderPath = "\(basePath)/\(format)"
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: folderPath) else { return [] }
        // Return filenames without extension
        return files.filter { $0.hasSuffix(".\(format)") }
                    .map { $0.replacingOccurrences(of: ".\(format)", with: "") }
    }
}
