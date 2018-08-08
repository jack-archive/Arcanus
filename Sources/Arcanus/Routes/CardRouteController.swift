// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

struct CardParam: Parameter {
    static func resolveParameter(_ parameter: String, on container: Container) throws -> DbfID {
        return try DbfID(parameter).unwrap(or: Abort(.unprocessableEntity, reason: "\(parameter) is not convertable to Int"))
    }
    
    typealias ResolvedParameter = DbfID
}

class CardRouteController: RouteCollection {
    func boot(router: Router) throws {
        let cards = router.grouped("games")
        cards.get(CardParam.parameter, use: getCardForIdHandler)
    }
}

private extension CardRouteController {
    func getCardForIdHandler(_ request: Request) throws -> Future<UsernameContainer> {
        let dbfId = try request.parameters.next(CardParam.self)
        let card = try CardIndex.getCard(dbfId).unwrap(or: Abort(.badRequest, reason: "No card with id \(dbfId)"))
        var response: CardResponse
    }
}
