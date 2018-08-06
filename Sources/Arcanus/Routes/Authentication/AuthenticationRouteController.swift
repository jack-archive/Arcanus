// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import Crypto
import Fluent
import Foundation
import Vapor

struct AuthenticationRouteController: RouteCollection {
    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "token")
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.post(UsernameContainer.self, at: "revoke", use: accessTokenRevocationhandler)
    }
}

//MARK: Helper

private extension AuthenticationRouteController {
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<AuthenticationContainer> {
        return try self.authController.authenticationContainer(for: container.refreshToken, on: request)
    }

    func accessTokenRevocationhandler(_ request: Request, container: UsernameContainer) throws -> Future<HTTPResponseStatus> {
        return try self.authController.revokeTokens(forUsername: container.username, on: request).transform(to: .noContent)
    }
}
