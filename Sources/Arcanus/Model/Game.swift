// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Foundation
import Vapor

struct AllowedCards: Content {
    var sets: [CardSet]
    var allowed: [DbfID]
    var unallowed: [DbfID]
    
    enum CodingKeys: CodingKey {
        case sets
        case allowed
        case unallowed
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.sets = try values.decode([String].self, forKey: .sets)
            .map({ CardSet(rawValue: $0) })
            .compactMap({ $0 }) // Unwrap
        self.allowed = try values.decode([DbfID].self, forKey: .allowed)
        self.unallowed = try values.decode([DbfID].self, forKey: .unallowed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sets.map({ $0.rawValue }), forKey: .sets)
        try container.encode(self.allowed, forKey: .allowed)
        try container.encode(self.unallowed, forKey: .unallowed)
    }
    
    func isAllowed(_ card: Card.Type) -> Bool {
        // return card.defaultCardStats
        return false
    }
}

final class Game: SQLiteModel, Content, Migration, Parameter {
    typealias ID = Int

    var id: ID?
    var player1: Player.ID?
    var player2: Player.ID?
    var allowedCards: AllowedCards?

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
