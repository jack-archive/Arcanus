typealias DbfID = Int

enum CardType: String, Codable {
    case minion = "MINION"
    case spell = "SPELL"
}

enum StatsStorage {
    case minion(MinionStats)
    case spell(SpellStats)
}

protocol CardStats: Codable {
    var dbfId: DbfID { get }
    var name: String { get set }
    var type: CardType { get }
}

protocol MinionStats: CardStats {
    var attack: Int { get set }
    var health: Int { get set }
}

extension CardStats where Self: MinionStats {
    var type: CardType { return .minion }
}

struct MinionStatsStruct: MinionStats {
    var dbfId: DbfID
    var name: String
    
    var attack: Int
    var health: Int
}

protocol SpellStats: CardStats {
    
}

extension CardStats where Self: SpellStats {
    var type: CardType { return .spell }
}

struct SpellStatsStruct: SpellStats {
    var dbfId: DbfID
    var name: String
}

protocol Card {
    static var cardStats: StatsStorage! { get }
    var cardStats: StatsStorage { get set }
}

protocol Minion: Card {
    
}

protocol Spell: Card {
    
}

class BloodfenRaptor: Minion {
    static var cardStats: StatsStorage!
    var cardStats: StatsStorage
    
    init() {
        self.cardStats = BloodfenRaptor.cardStats
    }
}

struct CardsJson: Decodable {
    var cards: [CardStats] = []
    
    enum TypeKey: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var copy = container
        while !container.isAtEnd {
            let card = try container.nestedContainer(keyedBy: TypeKey.self)
            let type = try card.decode(CardType.self, forKey: .type)
            switch type {
            case .minion:
                cards.append(try copy.decode(MinionStatsStruct.self))
            case .spell:
                cards.append(try copy.decode(SpellStatsStruct.self))
            }
        }
    }
}
