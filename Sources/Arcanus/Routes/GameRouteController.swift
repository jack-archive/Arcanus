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
        games.post(JoinGameContainer.self, at: "", use: createGameHandler)
        
        let players = games.grouped(Game.parameter, "players")
        players.post(JoinGameContainer.self, at: "", use: joinGameHandler)
    }
}

protocol DeckstringContainer: Content {
    var deckstring: String { get }
}

private extension GameRouteController {
    struct JoinGameContainer: DeckstringContainer {
        let deckstring: String
    }
    
    func createGameHandler(_ request: Request, container: JoinGameContainer) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        
        let player = try Player(user: user.id!, deckstring: container.deckstring).save(on: request)
        return player.flatMap { player in
            Game(p1: player.id!).save(on: request)
        }
    }
    
    func joinGameHandler(_ request: Request, container: JoinGameContainer) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        let player = try Player(user: user.id!, deckstring: container.deckstring).save(on: request) // Future
        let game = try request.parameters.next(Game.self)   // Future
        let logger = try request.make(Logger.self)
        
        
        return map(to: EventLoopFuture<Game>.self, player, game) { player, game in
            logger.info("\(user.username) joining game \(game.id!)")
            
            // addPlayer will return false if both player slots have values
            guard game.addPlayer(player.id!) else {
                throw Abort(.badRequest, reason: "Game is full")
            }
            
            // Log game
            try game.describe(on: request)
                .do({ logger.info($0) })
                .catch({ logger.error("\($0)") })
            
            return game.update(on: request)
        }.flatMap({ $0 })
    }
}
