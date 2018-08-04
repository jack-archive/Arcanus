// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import LoggerAPI
import SwiftKueryORM

final class Player: StringIDModel {
    var id: String
    var game: String {
        return String(self.id.split(separator: ":")[0])
    }

    var pid: Int {
        return Int(self.id.split(separator: ":")[1])!
    }

    var user: String

    static let P1ID = 0
    static let P2ID = 1

    static func joinID(_ game: String, _ pid: Int) -> String {
        return "\(game):\(pid)"
    }

    // Deckstring encoded in DB
    var handStorage: String = ""
    var deckStorage: String = ""

    var hand: [Card] {
        return []
    }

    var deck: [Card] {
        return []
    }

    init(game: String, pid: Int) throws {
        self.id = "\(game):\(pid)"
        self.user = Game.GameOpenUsername

        var error: Error?
        self.save { player, err in
            if player == nil || err != nil {
                error = ArcanusError.kituraError(err!)
                return
            }
        }
        if error != nil { throw error! }
        Log.verbose("Saved Player with id: \(self.id)")
    }
}
