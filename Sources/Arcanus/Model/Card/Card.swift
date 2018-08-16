// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

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

protocol Card: Entity, CustomStringConvertible {
    var enchantments: [Enchantment] { get set }

    static var defaultCardStats: CardStats { get }
    var cardStats: CardStats { get set }
}

extension Card {
    var description: String {
        return "\(self.name) [\(self.dbfId), \(self.cost) Mana, \(self.text)]"
    }
}

extension Card {
    static var dbfId: DbfID { return defaultCardStats.dbfId }
    static var name: String { return defaultCardStats.name }
    static var text: String { return defaultCardStats.text }
    static var flavor: String { return defaultCardStats.flavor }
    static var cls: CardClass { return defaultCardStats.cls }
    static var collectible: Bool { return defaultCardStats.collectible }
    static var type: CardType { return defaultCardStats.type }
    static var rarity: CardRarity { return defaultCardStats.rarity }
    static var set: CardSet { return defaultCardStats.set }
    static var gang: GadgetzanGang? { return defaultCardStats.gang }
    static var cost: Int { return defaultCardStats.cost }
    static var mechanics: [CardMechanic] { return defaultCardStats.mechanics }
    static var playRequirements: PlayRequirements { return defaultCardStats.playRequirements }

    var dbfId: DbfID { return cardStats.dbfId }
    var name: String { get { return cardStats.name } set { cardStats.name = newValue } }
    var text: String { get { return cardStats.text } set { cardStats.text = newValue } }
    var flavor: String { return cardStats.flavor }
    var cls: CardClass { get { return cardStats.cls } set { cardStats.cls = newValue } }
    var collectible: Bool { return cardStats.collectible }
    var rarity: CardRarity { return cardStats.rarity }
    var set: CardSet { return cardStats.set }
    var gang: GadgetzanGang? { return cardStats.gang }
    var cost: Int { get { return cardStats.cost } set { cardStats.cost = newValue } }
    var mechanics: [CardMechanic] {
        get { return cardStats.mechanics }
        set { cardStats.mechanics = newValue }
    }
    var playRequirements: PlayRequirements {
        get { return cardStats.playRequirements }
        set { cardStats.playRequirements = newValue }
    }
}

// MARK: Minion

protocol Minion: Card {
    static var defaultMinionStats: MinionStats { get }
    var minionStats: MinionStats { get set }
}

extension Minion {
    static var attack: Int { return defaultMinionStats.attack }
    static var health: Int { return defaultMinionStats.health }
    static var race: MinionRace { return defaultMinionStats.race }

    var attack: Int {
        get { return self.minionStats.attack }
        set { self.minionStats.attack = newValue }
    }

    var health: Int {
        get { return self.minionStats.health }
        set { self.minionStats.health = newValue }
    }

    var race: MinionRace { return minionStats.race }
}

// MARK: Spell

protocol Spell: Card {
    static var defaultSpellStats: SpellStats { get }
    var spellStats: SpellStats { get set }
}

extension Spell {
}

// MARK: Weapon

protocol Weapon: Card {
    static var defaultWeaponStats: WeaponStats { get }
    var weaponStats: WeaponStats { get set }
}

extension Weapon {
    static var attack: Int { return defaultWeaponStats.attack }
    static var durability: Int { return defaultWeaponStats.durability }

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

protocol Hero: Card {
    static var defaultHeroStats: HeroStats { get }
    var heroStats: HeroStats { get set }
}

extension Hero {
    static var health: Int { return defaultHeroStats.health }

    var health: Int {
        get { return self.heroStats.health }
        set { self.heroStats.health = newValue }
    }
}

// MARK: Hero Power

protocol HeroPower: Card {
    static var defaultHeroPowerStats: HeroPowerStats { get }
    var heroPowerStats: HeroPowerStats { get set }
}

extension HeroPower {
}

// MARK: Card Index

struct CardIndex {
    fileprivate static var CardNameIndex: [String: Card.Type] = [:]
    fileprivate static var CardDbfIDIndex: [DbfID: Card.Type] = [:]

    static func add(_ cards: Card.Type...) {
        for card in cards {
            self.CardNameIndex[card.defaultCardStats.name] = card
            self.CardDbfIDIndex[card.defaultCardStats.dbfId] = card
        }
    }

    static func getCard(_ dbfID: DbfID) -> Card.Type? {
        return self.CardDbfIDIndex[dbfID]
    }

    static func getCard(_ name: String) -> Card.Type? {
        return self.CardNameIndex[name]
    }

    static func getHero(_ dbfID: DbfID) -> Hero.Type? {
        return self.CardDbfIDIndex[dbfID] as? Hero.Type
    }

    static func getHero(_ name: String) -> Hero.Type? {
        return self.CardNameIndex[name] as? Hero.Type
    }
}
