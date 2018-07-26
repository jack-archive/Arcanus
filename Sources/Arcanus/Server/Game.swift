// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class Game: Codable {
    var id: Int32! = nil
    var user1: User! = nil
    var user2: User! = nil
    var state: String! = nil
    var config: String! = nil

    public static func makeGame(user: User) throws -> Game {
        let rv = Game()
        rv.user1 = user
        try Database.shared.initGame(game: rv)
        return rv
    }
}
