// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol IMinionStats {
    var attack: Int { get set }
    var health: Int { get set }
    var race: MinionRace { get }
}

class MinionStats: CardStats, IMinionStats {
    var attack: Int
    var health: Int
    var race: MinionRace

    convenience init(_ stats: CardStats, attack: Int, health: Int, race: MinionRace) {
        self.init(dbfId: stats.dbfId, name: stats.name, text: stats.text, flavor: stats.flavor, cost: stats.cost, cls: stats.cls,
                  collectible: stats.collectible, rarity: stats.rarity, set: stats.set, mechanics: stats.mechanics,
                  playRequirements: stats.playRequirements,
                  
                  attack: attack, health: health, race: race)
    }

    init(dbfId: DbfID, name: String, text: String, flavor: String, cost: Int, cls: CardClass, collectible: Bool,
         rarity: CardRarity, set: CardSet, mechanics: [CardMechanic], playRequirements: [PlayRequirement:Int],
         attack: Int, health: Int, race: MinionRace) {
        self.attack = attack
        self.health = health
        self.race = race

        super.init(dbfId: dbfId, name: name, text: text, flavor: flavor, cost: cost, cls: cls, collectible: collectible,
                   rarity: rarity, set: set, mechanics: mechanics, playRequirements: playRequirements)
    }
    
    override var type: CardType { return .minion }
}

protocol Minion: Card, IMinionStats {}

extension Minion {
    var isDead: Bool {
        return self.health < 0
    }
    
    var description: String {
        return "<>"
    }
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
            case let .minion(stats): self.stats = .minion(MinionStats(stats, attack: newValue, health: stats.health, race: stats.race))
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
            case let .minion(stats): self.stats = .minion(MinionStats(stats, attack: stats.attack, health: newValue, race: stats.race))
            default: fatalError()
            }
        }
    }
    
    var race: MinionRace {
        get {
            switch self.stats {
            case let .minion(stats): return stats.race
            default: fatalError()
            }
        }
        set {
            switch self.stats {
            case let .minion(stats): self.stats = .minion(MinionStats(stats, attack: stats.attack, health: stats.health, race: newValue))
            default: fatalError()
            }
        }
    }
}
