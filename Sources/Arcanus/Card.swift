// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Anything in the game is an entity, has a uid, unique from any other entity *in the game*.
/// Entities recieve events.
protocol Entity: AnyObject {
    
}

extension Entity {
    var uid: Int { get {
        return 1
        }}
}

enum CardClass: String {
    case neutral
    case druid
    case hunter
    case mage
    case paladin
    case priest
    case rouge
    case shaman
    case warlock
    case warrior
}

enum CardMechanic: String {
    case charge
    case taunt
    case windfury
    case battlecry
    case deathrattle
}

protocol Card: Entity {
    var enchantments: [Enchantment] { set get }
    
    static var defaultCardStats: CardStats { get }
    var cardStats: CardStats { get set }
}

extension Card {
    var dbfId: Int {
        set { cardStats.dbfId = newValue }
        get { return cardStats.dbfId }
    }
    var name: String {
        set { cardStats.name = newValue }
        get { return cardStats.name }
    }
    var cls: CardClass {
        set { cardStats.cls = newValue }
        get { return cardStats.cls }
    }
    var cost: Int {
        set { cardStats.cost = newValue }
        get { return cardStats.cost }
    }
    var mechanics: [CardMechanic] {
        set { cardStats.mechanics = newValue }
        get { return cardStats.mechanics }
    }
}

protocol Minion: Card {
    static var defaultMinionStats: MinionStats { get }
    var minionStats: MinionStats { get set }
}

extension Minion {
    var attack: Int {
        get { return self.minionStats.attack }
        set { self.minionStats.attack = newValue }
    }
    var health: Int { get {
            return self.minionStats.health
        } set {
            self.minionStats.health = newValue
        }}
}

final class SenjinShieldmasta: Minion {
    struct Stats: CardStats, MinionStats {
        var dbfId: Int = 635
        var name: String = "Sen'jin Shieldmasta"
        var cls: CardClass = .neutral
        var cost: Int = 4
        var mechanics: [CardMechanic] = [.taunt]
        var attack: Int = 3
        var health: Int = 5
    }
    
    static var defaultCardStats: CardStats { return Stats() }
    static var defaultMinionStats: MinionStats { return Stats() }
    var cardStats: CardStats = Stats()
    var minionStats: MinionStats = Stats()

    var enchantments: [Enchantment] = []
    
}

protocol Enchantment: Card {
    
}

/*
protocol Spell: Card {
    
}

extension Spell {
    var type: CardType { return .spell }
}

protocol Weapon: Card {
    var attack: Int { get }
    var durability: Int { get }
}

extension Weapon {
    var type: CardType { return .weapon }
}



extension Enchantment {
    var type: CardType { return .enchantment }
}
*/
