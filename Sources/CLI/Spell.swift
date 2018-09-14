// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol ISpellStats {}

class SpellStats: CardStats, ISpellStats {
    convenience init(_ stats: CardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name, text: stats.text, flavor: stats.flavor, cost: stats.cost, cls: stats.cls,
                  collectible: stats.collectible, rarity: stats.rarity, set: stats.set, mechanics: stats.mechanics,
                  playRequirements: stats.playRequirements)
    }

    override init(dbfId: DbfID, name: String, text: String, flavor: String, cost: Int, cls: CardClass, collectible: Bool, rarity: CardRarity, set: CardSet, mechanics: [CardMechanic], playRequirements: [PlayRequirement: Int]) {
        super.init(dbfId: dbfId, name: name, text: text, flavor: flavor, cost: cost, cls: cls, collectible: collectible,
                   rarity: rarity, set: set, mechanics: mechanics, playRequirements: playRequirements)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

protocol Spell: Card {
    func execute(game: Game) throws -> Bool
}
