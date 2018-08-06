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
        games.post(use: createGameHandler)
        
        let players = games.grouped(Game.parameter, "players")
        players.post(use: joinGameHandler)
    }
}

private extension GameRouteController {
    func createGameHandler(_ request: Request) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        
        let player = Player(user: user.id!)
        return player.save(on: request).flatMap { player in
            Game(p1: player.id!).save(on: request)
        }
    }
    
    func joinGameHandler(_ request: Request) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        let player = Player(user: user.id!)
        
        return try request.parameters.next(Game.self).flatMap { game in
            let logger = try request.make(Logger.self)
            logger.info("\(user.username) joining game \(game.id!)")
            
            game.player2 = player.id
            try game.describe(on: request).do({ logger.info($0) }).catch({ logger.error("\($0)") })
            
            return game.update(on: request)
        }
    }
}
