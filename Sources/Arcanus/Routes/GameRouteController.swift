// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import Fluent
import Crypto
import Logging

class GameRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("games")
        group.post("", use: createGameHandler)
    }
}

private extension GameRouteController {
    
    func createGameHandler(_ request: Request) throws -> Future<Game> {
        let user = try request.requireAuthenticated(User.self)
        let player = Player(user: user.id!)
        return player.save(on: request).flatMap { player in
            return Game(p1: player.id!).save(on: request)
        }
    }
    
    /*
    func registerUserHandler(_ request: Request, creds: Credentials) throws -> Future<AuthenticationContainer> {
        return User.query(on: request).filter(\.username == creds.username).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "user \(creds.username) already exists" , identifier: nil)
            }
            
            return try User(username: creds.username, toHash: creds.password).save(on: request).flatMap { user in
                
                let logger = try request.make(Logger.self)
                logger.warning("New user created: \(user.username)")
                
                return try self.authController.authenticationContainer(for: user, on: request)
            }
        }
    }
    */
}

