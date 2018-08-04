// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Anything in the game is an entity, has a uid, unique from any other entity *in the game*.
/// Entities recieve events.
protocol Entity: AnyObject {
    var uid: Int { get }
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

enum CardType: String {
    case minion
    case spell
    case weapon
    case enchantment
}

enum CardMechanics: String {
    case charge
    case taunt
    case windfury
    case battlecry
    case deathrattle
}

protocol Card: Entity {
    static var dbfId: Int { get }
    static var name: String { get }
    static var cls: CardClass { get }
    static var type: CardType { get }
    static var cost: Int { get }
    static var mechanics: [CardMechanics] { get }
    
    var dbfId: Int { set get }
    var name: String { set get }
    var cls: CardClass { set get }
    var type: CardType { set get }
    var cost: Int { set get }
    var mechanics: [CardMechanics] { set get }
    
    init()
    
    var enchantments: [Enchantment] { set get }
}

extension Card {
    init() {
        self.dbfId = Self.dbfId
        self.name = Self.name
        self.cls = Self.cls
        self.type = Self.type
        self.cost = Self.cost
        self.mechanics = Self.mechanics
        
        self.enchantments = []
    }
}

protocol Minion: Card {
    var attack: Int { get }
    var health: Int { get }
}

extension Minion {
    var type: CardType { return .minion }
    
    init() {
        
    }
}

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

protocol Enchantment: Card {
    
}

extension Enchantment {
    var type: CardType { return .enchantment }
}

final class SenjinShieldmasta: Minion {    
    var attack: Int = 3
    var health: Int = 5
    var dbfId: Int = 635
    var name: String = "Sen'jin Shieldmasta"
    var cls: CardClass = .neutral
    var cost: Int = 4
    
}
