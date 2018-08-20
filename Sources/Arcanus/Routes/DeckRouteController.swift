// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

class DeckRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.post("user", "collection", use: createDeckHandler)
        
    }
}

private extension DeckRouteController {
    func createDeckHandler(_ request: Request) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        
        var deck = try Deck.fromRequest(request)
        guard deck.name != nil else {
            throw Abort(.badRequest, reason: "Deck to be saved needs a a name")
        }
        deck.user = try user.requireID()
        
        
        return deck.save(on: request)
            .map { deck in deck.toNameJson() }
            .encode(status: .created, for: request)
    }
}
