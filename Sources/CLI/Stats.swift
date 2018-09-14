// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

typealias DbfID = Int

protocol IHeroStats {
    var health: Int { get set }
}

enum Stats: Codable {
    init(from decoder: Decoder) throws {
        fatalError()
    }

    func encode(to encoder: Encoder) throws {}

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
                self = .minion(MinionStats(stats, attack: stats.attack, health: stats.health, race: stats.race))
            case let .spell(stats):
                self = .spell(SpellStats(stats))
            }
        }
    }
}

class BloodfenRaptor: Minion {
    static var stats: Stats = .minion(MinionStats(dbfId: 216,
                                                  name: "Bloodfen Raptor",
                                                  text: "",
                                                  flavor: "\"Kill 30 raptors.\" - Hemet Nesingwary",
                                                  cost: 2,
                                                  cls: .neutral,
                                                  collectible: true,
                                                  rarity: .free,
                                                  set: .core,
                                                  mechanics: [],
                                                  playRequirements: [:],
                                                  attack: 3,
                                                  health: 2,
                                                  race: .beast))
    var stats: Stats

    required init() {
        self.stats = BloodfenRaptor.stats
    }
}

class TheCoin: Spell {
    static var stats: Stats = .spell(SpellStats(dbfId: 1746,
                                                name: "The Coin",
                                                text: "Gain 1 Mana Crystal this turn only.",
                                                flavor: "",
                                                cost: 0,
                                                cls: .neutral,
                                                collectible: false,
                                                rarity: .free,
                                                set: .core,
                                                mechanics: [],
                                                playRequirements: [:]))
    var stats: Stats

    required init() {
        self.stats = TheCoin.stats
    }

    func execute(game: Game) throws -> Bool {
        game.currentPlayer.bonusMana += 1
        return true
    }
}
