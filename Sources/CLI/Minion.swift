//
//  Minion.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 9/2/18.
//

import Foundation

class MinionStats: CardStats, IMinionStats {
    var attack: Int
    var health: Int

    convenience init(_ stats: ICardStats, attack: Int, health: Int) {
        self.init(dbfId: stats.dbfId, name: stats.name, cost: stats.cost, attack: attack, health: health)
    }

    init(dbfId: DbfID, name: String, cost: Int, attack: Int, health: Int) {
        self.dbfId = dbfId
        self.name = name
        self.cost = cost

        self.attack = attack
        self.health = health
    }
}

protocol Minion: Card, IMinionStats {}

extension Minion {
    var isDead: Bool {
        return self.health < 0
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
