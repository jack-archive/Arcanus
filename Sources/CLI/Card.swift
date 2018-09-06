// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol ICardStats: AnyObject {
    var dbfId: DbfID { get }
    var stringID: String { get }
    var name: String { get set }
    var text: String { get set }
    var flavor: String { get }
    // var cls: CardClass { get set }
    var collectible: Bool { get }
    // var type: CardType { get }
    var rarity: CardRarity { get }
    var set: CardSet { get }
    // var gang: GadgetzanGang? { get }
    var cost: Int { get set }
    // var mechanics: [CardMechanic] { get set }
    // var playRequirements: PlayRequirements { get set }
}

protocol Card: ICardStats, CustomStringConvertible {
    static var stats: Stats { get }
    var stats: Stats { get set }

    init()
}

extension Card {
    var description: String {
        return "<\(self.name) (\(self.cost)) \(self.text)>"
    }
}

extension Card {
    var dbfId: DbfID { return self.stats.cardStats.dbfId }
    var stringID: String { return self.stats.cardStats.stringID }
    var name: String { get { return self.stats.cardStats.name } set { self.stats.cardStats.name = newValue } }
    var text: String { get { return self.stats.cardStats.text } set { self.stats.cardStats.text = newValue } }
    var flavor: String { return self.stats.cardStats.flavor }
    var collectible: Bool { return self.stats.cardStats.collectible }
    var rarity: CardRarity { return self.stats.cardStats.rarity }
    var set: CardSet { return self.stats.cardStats.set }
    var cost: Int { get { return self.stats.cardStats.cost } set { self.stats.cardStats.cost = newValue } }
}
