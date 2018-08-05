// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class Game: SQLiteModel, Content, Migration {
    typealias ID = Int
    
    var id: ID?
    private(set) var player1: Player.ID?
    private(set) var player2: Player.ID?
    
    init(p1: Player.ID) {
        self.player1 = p1
    }
}
