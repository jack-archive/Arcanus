// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import FluentSQLite
import Foundation
import Vapor

typealias DbfID = Int

/// Anything in the game is an entity, has a uid, unique from any other entity *in the game*.
/// Entities recieve events.
protocol Entity {
    var uid: Int { get }
}

extension Entity {
    var uid: Int {
        // TODO: Implement this
        return 1
    }
}

// MARK: Card

protocol Card: Entity, CustomStringConvertible, CustomDebugStringConvertible {
    var enchantments: [Any & Enchantment] { get set }

    static var defaultCardStats: CardStats { get }
    var cardStats: CardStats { get set }
}

extension Card {
    var description: String {
        return "\(self.name) (\(self.type)) [\(self.dbfId), \(self.cost) Mana, \(self.text)]"
    }
    
    var debugDescription: String {
        return String(reflecting: self.cardStats)
    }
}

protocol CardStats: Codable {
    var dbfId: DbfID { get }
    var name: String { get set }
    var text: String { get set }
    var flavor: String { get }
    var cls: CardClass { get set }
    var collectible: Bool { get }
    var type: CardType { get }
    var rarity: CardRarity { get }
    var set: CardSet { get }
    var gang: GadgetzanGang? { get }
    var cost: Int { get set }
    var mechanics: [CardMechanic] { get set }
    var playRequirements: PlayRequirements { get set }
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
    var type: CardType { return cardStats.type }
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
