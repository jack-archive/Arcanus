// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Player {
    var deck: [Card] = []
    var hand: [Card] = []
    var board: [Minion] = []
    var controller: PlayerController

    init(_ controller: PlayerController) {
        self.controller = controller
        self.deck = self.controller.getDeck()
    }

    // MARK: Mana

    var mana: Int {
        var rv = manaCrystals
        rv += bonusMana
        rv -= usedMana
        rv -= lockedMana
        return rv
    }

    var usedMana: Int = 0
    var manaCrystals: Int = 0
    var bonusMana: Int = 0
    var lockedMana: Int = 0
    var overloadedMana: Int = 0

    mutating func spendMana(_ manaToSpend: Int) -> Bool {
        if self.mana < manaToSpend || manaToSpend < 0 {
            return false
        } else {
            self.usedMana += manaToSpend
            return true
        }
    }

    mutating func drawCard() {
        self.hand.append(self.deck.remove(at: 0))
    }
}
