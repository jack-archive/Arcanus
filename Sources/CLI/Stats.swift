// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

typealias DbfID = Int

enum CardType: String, Codable {
    case minion = "MINION"
    case spell = "SPELL"
    case weapon = "WEAPON"
    case hero = "HERO"
}

enum CardRarity: String, Codable {
    case free = "FREE"
    case common = "COMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"
}

enum CardSet: String, Codable {
    case core = "CORE"
    case classic = "EXPERT1"
    case hof = "HOF" // Hall of Fame
}

enum PlayRequirement: String, Codable {
    case minionTarget = "REQ_MINION_TARGET"
    case targetIfAvaliable = "REQ_TARGET_IF_AVAILABLE"
    case targetToPlay = "REQ_TARGET_TO_PLAY"
    case entireEntourageNotInPlay = "REQ_ENTIRE_ENTOURAGE_NOT_IN_PLAY"
    case numMinionSlots = "REQ_NUM_MINION_SLOTS"
}

enum CardMechanic: String, Codable {
    case charge = "STEALTH"
    case taunt = "TAUNT"
}

protocol IMinionStats {
    var attack: Int { get set }
    var health: Int { get set }
}

protocol IHeroStats {
    var health: Int { get set }
}

class CardStats: ICardStats {
    var dbfId: DbfID
    var name: String
    var text: String
    var cost: Int

    init(dbfId: DbfID, name: String, text: String, cost: Int) {
        self.dbfId = dbfId
        self.name = name
        self.text = text
        self.cost = cost
    }
}
 
enum Stats {
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
}

class BloodfenRaptor: Minion {
    static var stats: Stats = .minion(MinionStats(dbfId: 576, name: "Bloodfen Raptor", text: "", cost: 2, attack: 3, health: 2))
    var stats: Stats

    required init() {
        self.stats = BloodfenRaptor.stats
    }
}

class TheCoin: Spell {
    static var stats: Stats = .spell(SpellStats(dbfId: 141, name: "The Coin", text: "Gain one mana cryxtal", cost: 0))
    var stats: Stats

    required init() {
        self.stats = TheCoin.stats
    }

    func execute(game: Game) throws -> Bool {
        game.currentPlayer.bonusMana += 1
        return true
    }
}
