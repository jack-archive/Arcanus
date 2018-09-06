// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class MinionStats: CardStats, IMinionStats {
    var attack: Int
    var health: Int

    convenience init(_ stats: CardStats, attack: Int, health: Int) {
        self.init(dbfId: stats.dbfId, name: stats.name, text: stats.text, cost: stats.cost, attack: attack, health: health)
    }

    init(dbfId: DbfID, name: String, text: String, cost: Int,
         attack: Int, health: Int) {
        self.attack = attack
        self.health = health

        super.init(dbfId: dbfId, name: name, text: text, cost: cost)
    }
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
}
