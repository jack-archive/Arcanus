// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class SpellStats: CardStats {
    convenience init(_ stats: CardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name, text: stats.text, cost: stats.cost)
    }
}

protocol Spell: Card {
    func execute(game: Game) throws -> Bool
}
