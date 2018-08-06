// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Crypto
import Fluent
import Logging
import Vapor

class UserRouteController: RouteCollection {
    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(Credentials.self, at: "login", use: loginUserHandler)
        group.post(Credentials.self, at: "register", use: registerUserHandler)
    }
}

struct Credentials: Content {
    var username: String
    var password: String
}

private extension UserRouteController {
    func loginUserHandler(_ request: Request, creds: Credentials) throws -> Future<AuthenticationContainer> {
        return User.query(on: request).filter(\.username == creds.username).first().flatMap { existingUser in
            guard let existingUser = existingUser else {
                throw Abort(.badRequest, reason: "User \(creds.username) does not exist", identifier: nil)
            }

            guard try existingUser.verify(creds.password) else {
                throw Abort(.badRequest) /* authentication failure */
            }

            return try self.authController.authenticationContainer(for: existingUser, on: request)
        }
    }

    func registerUserHandler(_ request: Request, creds: Credentials) throws -> Future<Response> {
        return User.query(on: request).filter(\.username == creds.username).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "user \(creds.username) already exists", identifier: nil)
            }

            return try User(username: creds.username, toHash: creds.password).save(on: request).flatMap { user in

                let logger = try request.make(Logger.self)
                logger.warning("New user created: \(user.username)")
                
                return try self.authController.authenticationContainer(for: user, on: request)
                    .encode(status: .created, for: request)
            }
        }
    }
}
