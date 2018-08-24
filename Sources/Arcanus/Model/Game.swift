// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Foundation
import Vapor

struct Game: SQLiteModel, Content, Migration, Parameter {
    typealias ID = Int

    var id: ID?
    // On game start, players are ordered in here by who goes first
    var players: [Player] = []
    var board: [[Card]] = [[], []]
    // var events: [Event] = []
    // var allowedCards: AllowedCards?

    enum CodingKeys: CodingKey {
        case id
        case players
        case board
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(ID?.self, forKey: .id)
        self.players = try values.decode([Player].self, forKey: .players)
        // self.board = try values.decode([[Card]].self, forKey: .board)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }

    init() throws {}

    @discardableResult
    mutating func addPlayer(_ user: User.ID, _ deck: Deck.ID) -> Bool {
        guard self.isFull else {
            return false
        }

        self.players.append(Player(user: user, deck: deck))
        return true
    }

    var isFull: Bool {
        // Sanity Check
        assert(self.players.count <= 2 && self.players.count >= 0)
        return self.players.count == 2
    }

    func describe(on db: DatabaseConnectable) throws -> Future<String> {
        let user1 = User.find(players[.first].user, on: db).unwrap(or: Abort(.badRequest)).map({ $0.username })
        let user2 = User.find(players[.second].user, on: db).unwrap(or: Abort(.badRequest)).map({ $0.username })

        return map(to: String.self, user1, user2) {
            "<Game (\(self.id?.description ?? "unsaved")) [\($0), \($1)]>"
        }
    }

    mutating func start() throws {
        if !self.isFull {
            throw Abort(.badRequest, reason: "Game needs another player")
        }

        // Randomly assign first / second
        if try CryptoRandom().generate() {
            // Swap order
            self.players.append(self.players[.first])
            self.players.remove(at: Side.first.rawValue)
        } else { /* Leave order the same */ }

        // state.changes.append(.start(players: self.players))
    }
}

struct Player: Codable {
    var user: User.ID
    var deck: Deck.ID
}

enum Side: Int {
    case first = 0, second = 1
}

typealias Board = [[Card]]

extension Array where Element == [Card] {
    subscript(side: Side) -> Element {
        return self[side.rawValue]
    }
}

extension Array where Element == Player {
    subscript(side: Side) -> Element {
        return self[side.rawValue]
    }
}

class GameHistory {
}
