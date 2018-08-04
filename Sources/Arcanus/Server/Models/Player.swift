// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKueryORM

struct Player: Model {
    var game: String
    var pid: Int

    var id: String {
        return "\(self.game):\(self.pid)"
    }

    // Deckstring encoded in DB
    var handStorage: String
    var deckStorage: String

    var hand: [Card] {
        return []
    }

    var deck: [Card] {
        return []
    }
}
