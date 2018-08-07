// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

typealias DbfID = Int

/// Anything in the game is an entity, has a uid, unique from any other entity *in the game*.
/// Entities recieve events.
protocol Entity: AnyObject {
    var uid: Int { get }
}

extension Entity {
    var uid: Int {
        // TODO: Implement this
        return 1
    }
}

// MARK: Card

enum CardRarity: String {
    case free, common, rare, epic, legendary
}

enum CardSet: String {
    case basic, classic
}

// http://hearthstone.wikia.com/wiki/Race
enum CardRace: String {
    case neutral
}

enum CardClass: String {
    case neutral
    case druid, hunter, mage,
        paladin, priest, rouge,
        shaman, warlock, warrior
}

enum CardMechanic: String {
    case charge
    case taunt
    case windfury
    case battlecry
    case deathrattle

    case oneTurnEffect
}

protocol CardStats {
    var dbfId: DbfID { get set }
    var name: String { get set }
    var text: String { get set }
    var cls: CardClass { get set }
    var cost: Int { get set }
    var mechanics: [CardMechanic] { get set }
}

protocol Card: Entity {
    var enchantments: [Enchantment] { get set }

    static var defaultCardStats: CardStats { get }
    var cardStats: CardStats { get set }
}

extension Card {
    var dbfId: DbfID {
        set { cardStats.dbfId = newValue }
        get { return cardStats.dbfId }
    }

    var name: String {
        set { cardStats.name = newValue }
        get { return cardStats.name }
    }

    var text: String {
        set { cardStats.text = newValue }
        get { return cardStats.text }
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

// MARK: Minion

protocol MinionStats {
    var attack: Int { get set }
    var health: Int { get set }
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

    var health: Int {
        get { return self.minionStats.health }
        set { self.minionStats.health = newValue }
    }
}

// MARK: Spell

protocol SpellStats {
}

protocol Spell: Card {
    static var defaultSpellStats: SpellStats { get }
    var spellStats: SpellStats { get set }
}

extension Spell {
}

// MARK: Weapon

protocol WeaponStats {
    var attack: Int { get set }
    var durability: Int { get set }
}

protocol Weapon: Card {
    static var defaultWeaponStats: WeaponStats { get }
    var weaponStats: WeaponStats { get set }
}

extension Weapon {
    var attack: Int {
        get { return self.weaponStats.attack }
        set { self.weaponStats.attack = newValue }
    }

    var durability: Int {
        get { return self.weaponStats.durability }
        set { self.weaponStats.durability = newValue }
    }
}

// MARK: Enchantment

protocol EnchantmentStats {
}

protocol Enchantment: Card {
    static var defaultEnchantmentStats: EnchantmentStats { get }
    var enchantmentStats: EnchantmentStats { get set }
}

extension CardStats where Self: EnchantmentStats {
    var cost: Int { return 0 }
}

extension Enchantment {
}

// MARK: Hero

protocol HeroStats {
    var health: Int { get set }
}

protocol Hero: Card {
    static var defaultHeroStats: HeroStats { get }
    var heroStats: HeroStats { get set }
}

extension Hero {
    var health: Int {
        get { return self.heroStats.health }
        set { self.heroStats.health = newValue }
    }
}

// MARK: Hero Power

protocol HeroPowerStats {
}

protocol HeroPower: Card {
    static var defaultHeroPowerStats: HeroPowerStats { get }
    var heroPowerStats: HeroPowerStats { get set }
}

extension HeroPower {
}

// MARK: Card Index

struct CardIndex {
    fileprivate var CardNameIndex: [String: Card.Type] = [:]
    fileprivate var CardDbfIDIndex: [DbfID: Card.Type] = [:]
    
    func get<T: Card>(_ type: T.Type? = nil, _ dbfID: DbfID) -> T.Type? {
        return CardDbfIDIndex[dbfID] as? T.Type
    }
    
    func get<T: Card>(_ name: String) -> T.Type? {
        return CardNameIndex[name] as? T.Type
    }

}
