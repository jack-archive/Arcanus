typealias DbfID = Int

enum CardType: String, Codable {
    case minion = "MINION"
    case spell = "SPELL"
}

protocol CardStats {
    var dbfId: DbfID { get }
    var name: String { get set }
    // var type: CardType
}

protocol IMinionStats {
    var attack: Int { get set }
    var health: Int { get set }
}

class MinionStats: CardStats, IMinionStats {
    var dbfId: DbfID
    var name: String
    
    var attack: Int
    var health: Int
    
    convenience init(_ stats: CardStats, attack: Int, health: Int) {
        self.init(dbfId: stats.dbfId, name: stats.name, attack: attack, health: health)
    }
    
    init(dbfId: DbfID, name: String, attack: Int, health: Int) {
        self.dbfId = dbfId
        self.name = name
        
        self.attack = attack
        self.health = health
    }
}

class SpellStats: CardStats {
    var dbfId: DbfID
    var name: String
    
    convenience init(_ stats: CardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name)
    }
    
    
    init(dbfId: DbfID, name: String) {
        self.dbfId = dbfId
        self.name = name
    }
}

enum Stats: CardStats {
    case minion(MinionStats)
    case spell(SpellStats)
    
    var cardStats: CardStats {
        get {
            switch self {
            case .minion(let stats):
                return stats
            case .spell(let stats):
                return stats
            }
        }
        
        set {
            switch self {
            case .minion(let stats):
                self = .minion(MinionStats(stats, attack: stats.attack, health: stats.health))
            case .spell(let stats):
                self = .spell(SpellStats(stats))
            }
        }
    }
    
    var dbfId: DbfID { return self.cardStats.dbfId }
    var name: String { get { return self.cardStats.name } set { self.cardStats.name = newValue }}
}

protocol Card: AnyObject {
    static var stats: Stats { get }
    var stats: Stats { get set }
    
    init()
}

extension Card {
    
}

protocol Minion: Card, IMinionStats {
    
}

extension Minion {
    var attack: Int {
        get {
            switch self.stats {
            case .minion(let stats): return stats.attack
            default: fatalError()
            }
        }
        set {
            switch self.stats {
            case .minion(let stats): self.stats = .minion(MinionStats(stats, attack: newValue, health: stats.health))
            default: fatalError()
            }
        }
    }
    
    var health: Int {
        get {
            switch self.stats {
            case .minion(let stats): return stats.health
            default: fatalError()
            }
        }
        set {
            switch self.stats {
            case .minion(let stats): self.stats = .minion(MinionStats(stats, attack: stats.attack, health: newValue))
            default: fatalError()
            }
        }
    }
    
    var isDead: Bool {
        return self.health < 0
    }
}

protocol Spell: Card {
    
}

class BloodfenRaptor: Minion {
    static var stats: Stats = .minion(MinionStats(dbfId: 576, name: "Bloodfen Raptor", attack: 3, health: 2))
    var stats: Stats
    
    required init() {
        self.stats = BloodfenRaptor.stats
    }
}

class TheCoin: Spell {
    static var stats: Stats = .spell(SpellStats(dbfId: 141, name: "The Coin"))
    var stats: Stats
    
    required init() {
        self.stats = TheCoin.stats
    }
}
