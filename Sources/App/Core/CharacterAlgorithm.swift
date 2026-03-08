import Vapor

protocol CharacterAlgorithm {
    var name: String { get }
    var world: String { get }
    var country: String { get }
    var region: String { get }
    var colorHex: String { get }
    
    func apply(to grid: Grid, using rng: inout SeededGenerator)
}

struct CharacterRegistry {
    static let all: [CharacterAlgorithm] = [
        Tintin(),
        Haddock(),
        Milou(),
        Rastapopoulos(),
        Marsupilami(),
        Gaston(),
        MelleJeanne(),
        Prunelle(),
        Winnie(),
        Bourriquet(),
        Tigrou(),
        Luffy(),
        Zoro(),
        Goku(),
        Vegeta(),
        Quetzalcoatl(),
        Tezcatlipoca(),
        Anansi(),
        Thor(),
        Loki(),
        SunWukong(),
        Batman(),
        SpiderMan(),
        Baahubali(),
        Elsa(),
        Shrek(),
        Minion(),
        Homer(),
        HarryPotter(),
        Parcival()
    ]
    
    static func get(name: String) -> CharacterAlgorithm? {
        return all.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getBySeries(_ series: String) -> [CharacterAlgorithm] {
        return all.filter { $0.world.replacingOccurrences(of: " ", with: "").lowercased() == series.lowercased() }
    }
}
