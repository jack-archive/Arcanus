// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

class DeckRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.post(Deck.DbfIDJson.self, at: "user", "collection", use: createDeckHandler)
        router.post(Deck.NameJson.self, at: "user", "collection", use: createDeckHandler)
        router.post(Deck.DeckstringJson.self, at: "user", "collection", use: createDeckHandler)
    }
}

private extension DeckRouteController {
    func createDeckHandler(_ request: Request, container: DeckConvertible) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        
        var deck = try container.asDeck()
        guard deck.name != nil else {
            throw Abort(.badRequest, reason: "Deck to be saved needs a a name")
        }
        deck.user = try user.requireID()
        
        return deck.save(on: request)
            .map { deck in deck.toNameJson() }
            .encode(status: .created, for: request)
    }
}
