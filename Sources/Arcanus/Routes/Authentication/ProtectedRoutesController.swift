// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import Authentication
import Crypto

struct ProtectedRoutesController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        // basicAuthGroup.get("basic", use: basicAuthRouteHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        // tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
        
        try tokenAuthGroup.register(collection: GameRouteController())
    }
}

//MARK: Helper
private extension ProtectedRoutesController {
    /*
    func basicAuthRouteHandler(_ request: Request) throws -> AuthenticationContainer {
        return try request.requireAuthenticated(User.self)
    }
    
    func tokenAuthRouteHandler(_ request: Request) throws -> User {
        return try request.requireAuthenticated(User.self)
    }
 */
}
