// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Foundation
import Vapor

final class Player: SQLiteModel, Content, Migration {
    typealias ID = Int

    var id: ID?
    private(set) var user: User.ID
    private(set) var deck: Deck.ID

    init(user: User.ID, deck: Deck.ID) throws {
        self.user = user
        self.deck = deck
    }

    func getUser(on db: DatabaseConnectable) throws -> Future<User> {
        return User.query(on: db).filter(\.id == self.user).first()
            .unwrap(or: Abort(.internalServerError,
                              reason: "Player \(self.id?.description ?? "NO ID (Unsaved)") bad user"))
    }

    static func get(on db: DatabaseConnectable, id: ID) -> Future<Player> {
        return Player.query(on: db).filter(\.id == id).first()
            .unwrap(or: Abort(.badRequest, reason: "No player with id \(id)"))
    }
}
