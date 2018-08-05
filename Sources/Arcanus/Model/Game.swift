// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Foundation
import Vapor

final class Game: SQLiteModel, Content, Migration, Parameter {
    typealias ID = Int

    var id: ID?
    var player1: Player.ID?
    var player2: Player.ID?

    init(p1: Player.ID) {
        self.player1 = p1
    }
}
