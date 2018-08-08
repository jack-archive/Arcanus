// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Crypto
import Fluent
import Foundation
import Logging
import Vapor

class GameRouteController: RouteCollection {
    func boot(router: Router) throws {
        let games = router.grouped("games")
        games.post(DeckContainer.self, at: "", use: createGameHandler)
        
        let players = games.grouped(Game.parameter, "players")
        players.post(DeckContainer.self, at: "", use: joinGameHandler)
    }
}

private extension GameRouteController {
    struct DeckContainer: Content {
        let deckstring: String?
        let deck: DbfIDDeckJson?
        
        func asDeck() throws -> Deck {
            if deckstring != nil {
                return try Deck(fromDeckstring: deckstring!)
            } else if deck != nil {
                return try Deck(fromJson: deck!)
            } else {
                throw Abort(.badRequest, reason: "Must supply either Deck Json or Deckstring")
            }
        }
    }
    
    func createGameHandler(_ request: Request, container: DeckContainer) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        return try container.asDeck().save(on: request).flatMap { deck in
            return try Player(user: user.id!, deck: deck.requireID()).save(on: request).flatMap { player in
                Game(p1: player.id!).save(on: request)
            }
        }
    }
    
    func joinGameHandler(_ request: Request, container: DeckContainer) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        let game = try request.parameters.next(Game.self)
        let logger = try request.make(Logger.self)
        
        return try container.asDeck().save(on: request).flatMap { deck in
            let player = try Player(user: user.id!, deck: deck.requireID()).save(on: request)
            
            return flatMap(to: Game.self, player, game) { player, game in
                logger.info("\(user.username) joining game \(game.id!)")
                
                // addPlayer will return false if both player slots have values
                guard game.addPlayer(player.id!) else {
                    throw Abort(.badRequest, reason: "Game is full")
                }
                
                // Log game
                try game.describe(on: request)
                    .do({ logger.info($0) })
                    .catch({ logger.error($0.localizedDescription) })
                
                return game.update(on: request)
            }
        }
    }
}
