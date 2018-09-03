// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class CLIController: PlayerController {
    var game: Game!
    var side: Side!

    func getDeck() -> [Card] {
        return [BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor()]
    }

    func chooseAction() -> PlayerAction {
        print("? ")
        print(self.game.players[.first].hand)
        if let typed = readLine() {
            if let num = Int(typed) {
                print(num)
                switch num {
                case 0: return .playCard(fromHand: 0, toBoard: 0)
                case 1: return .endTurn
                case 2: return .combat(from: 0, to: 0)
                default: fatalError()
                }
            }
        }

        fatalError()
    }
}
