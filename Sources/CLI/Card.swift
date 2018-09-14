// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol ICardStats: AnyObject, Codable {
    var dbfId: DbfID { get }
    var name: String { get set }
    var text: String { get set }
    var flavor: String { get }
    var cost: Int { get set }
    var cls: CardClass { get }
    var collectible: Bool { get }
    var type: CardType { get }
    var rarity: CardRarity { get }
    var set: CardSet { get }
    // var gang: GadgetzanGang? { get }
    var mechanics: [CardMechanic] { get set }
    var playRequirements: [PlayRequirement: Int] { get set }
}

class CardStats: ICardStats {
    var dbfId: DbfID
    var name: String
    var text: String
    var flavor: String
    var cost: Int
    var cls: CardClass
    var collectible: Bool
    var type: CardType { fatalError() }
    var rarity: CardRarity
    var set: CardSet
    var mechanics: [CardMechanic]
    var playRequirements: [PlayRequirement: Int]

    init(dbfId: DbfID, name: String, text: String, flavor: String, cost: Int, cls: CardClass, collectible: Bool,
         rarity: CardRarity, set: CardSet, mechanics: [CardMechanic], playRequirements: [PlayRequirement: Int]) {
        self.dbfId = dbfId
        self.name = name
        self.text = text
        self.flavor = flavor
        self.cost = cost
        self.cls = cls
        self.collectible = collectible
        self.rarity = rarity
        self.set = set
        self.mechanics = mechanics
        self.playRequirements = playRequirements
    }
}

protocol Card: ICardStats, CustomStringConvertible {
    static var stats: Stats { get }
    var stats: Stats { get set }

    init()
}

extension Card {
    var description: String {
        var rv = "<\(self.name) (\(self.cost))"
        if !self.text.isEmpty {
            rv += " \(self.text)"
        }

        if let minion = self as? Minion {
            rv += " [\(minion.attack)/\(minion.health)]"
        }

        return rv + ">"
    }
}

extension Card {
    var dbfId: DbfID { return self.stats.cardStats.dbfId }
    var name: String { get { return self.stats.cardStats.name } set { self.stats.cardStats.name = newValue } }
    var text: String { get { return self.stats.cardStats.text } set { self.stats.cardStats.text = newValue } }
    var flavor: String { return self.stats.cardStats.flavor }
    var cost: Int { get { return self.stats.cardStats.cost } set { self.stats.cardStats.cost = newValue } }
    var cls: CardClass { return self.stats.cardStats.cls }
    var collectible: Bool { return self.stats.cardStats.collectible }
    var type: CardType { return self.stats.cardStats.type }
    var rarity: CardRarity { return self.stats.cardStats.rarity }
    var set: CardSet { return self.stats.cardStats.set }
    var mechanics: [CardMechanic] { get { return self.stats.cardStats.mechanics } set { self.stats.cardStats.mechanics = newValue } }
    var playRequirements: [PlayRequirement: Int] {
        get { return self.stats.cardStats.playRequirements } set { self.stats.cardStats.playRequirements = newValue } }
}
