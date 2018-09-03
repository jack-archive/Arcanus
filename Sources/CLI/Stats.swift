// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

typealias DbfID = Int

enum CardType: String, Codable {
    case minion = "MINION"
    case spell = "SPELL"
}

protocol ICardStats {
    var dbfId: DbfID { get }
    var name: String { get set }
    // var type: CardType
}

protocol IMinionStats {
    var attack: Int { get set }
    var health: Int { get set }
}

class MinionStats: ICardStats, IMinionStats {
    var dbfId: DbfID
    var name: String

    var attack: Int
    var health: Int

    convenience init(_ stats: ICardStats, attack: Int, health: Int) {
        self.init(dbfId: stats.dbfId, name: stats.name, attack: attack, health: health)
    }

    init(dbfId: DbfID, name: String, attack: Int, health: Int) {
        self.dbfId = dbfId
        self.name = name

        self.attack = attack
        self.health = health
    }
}

class SpellStats: ICardStats {
    var dbfId: DbfID
    var name: String

    convenience init(_ stats: ICardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name)
    }

    init(dbfId: DbfID, name: String) {
        self.dbfId = dbfId
        self.name = name
    }
}

enum Stats: ICardStats {
    case minion(MinionStats)
    case spell(SpellStats)

    var cardStats: ICardStats {
        get {
            switch self {
            case let .minion(stats):
                return stats
            case let .spell(stats):
                return stats
            }
        }

        set {
            switch self {
            case let .minion(stats):
                self = .minion(MinionStats(stats, attack: stats.attack, health: stats.health))
            case let .spell(stats):
                self = .spell(SpellStats(stats))
            }
        }
    }

    var dbfId: DbfID { return self.cardStats.dbfId }
    var name: String { get { return self.cardStats.name } set { self.cardStats.name = newValue } }
}

protocol Card: AnyObject, ICardStats, CustomStringConvertible {
    static var stats: Stats { get }
    var stats: Stats { get set }

    init()
}

extension Card {
    var description: String {
        return "<\(self.name)>"
    }

    var dbfId: DbfID { return self.stats.dbfId }
    var name: String { get { return self.stats.name } set { self.stats.name = newValue } }
}

protocol Minion: Card, IMinionStats {
}

extension Minion {
    var attack: Int {
        get {
            switch self.stats {
            case let .minion(stats): return stats.attack
            default: fatalError()
            }
        }
        set {
            switch self.stats {
            case let .minion(stats): self.stats = .minion(MinionStats(stats, attack: newValue, health: stats.health))
            default: fatalError()
            }
        }
    }

    var health: Int {
        get {
            switch self.stats {
            case let .minion(stats): return stats.health
            default: fatalError()
            }
        }
        set {
            switch self.stats {
            case let .minion(stats): self.stats = .minion(MinionStats(stats, attack: stats.attack, health: newValue))
            default: fatalError()
            }
        }
    }

    var isDead: Bool {
        return self.health < 0
    }
}

protocol Spell: Card {
    func execute(game: Game) throws -> Bool
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

    func execute(game: Game) throws -> Bool {
        game.currentPlayer.bonusMana += 1
        return true
    }
}
