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
    
    func addPlayer(_ id: Player.ID) -> Bool {
        if player1 == nil {
            player1 = id
            return true
        } else if player2 == nil {
            player2 = id
            return true
        } else {
            return false
        }
    }
    
    func describe(on db: DatabaseConnectable) throws -> Future<String> {
        guard player1 != nil, player2 != nil else {
            throw Abort(.badRequest, reason: "Game incomplete")
        }
        
        let user1 = Player.get(on: db, id: player1!).flatMap({ try $0.getUser(on: db) })
        let user2 = Player.get(on: db, id: player2!).flatMap({ try $0.getUser(on: db) })
        
        return map(to: String.self, user1, user2) {
            return "Game \(self.id!) [\($0.username), \($1.username)]"
        }
    }
}
