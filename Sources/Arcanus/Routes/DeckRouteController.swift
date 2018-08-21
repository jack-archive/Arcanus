// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Fluent
import Foundation
import Vapor

struct DeckIDParam: Parameter {
    static func resolveParameter(_ parameter: String, on container: Container) throws -> ResolvedParameter {
        return try Deck.ID(parameter).unwrap(or: Abort(.unprocessableEntity, reason: "\(parameter) is not convertable to Int"))
    }

    typealias ResolvedParameter = Deck.ID
}

class DeckRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.post("user", "collection", use: createDeckHandler)
        router.get("user", "collection", use: getAllDecksHandler)
        router.get("user", "collection", DeckIDParam.parameter, use: getDeckHandler)
        router.delete("user", "collection", DeckIDParam.parameter, use: deleteDeckHandler)
        router.put([DbfID].self, at: "user", "collection", DeckIDParam.parameter, use: setCardsInDeckHandler)
    }
}

private extension DeckRouteController {
    func createDeckHandler(_ request: Request) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)

        var deck = try Deck.fromRequest(request)
        guard deck.name != nil else {
            throw Abort(.badRequest, reason: "Deck to be saved needs a a name")
        }

        return Deck.query(on: request).filter(\.user == user.id).filter(\.name == deck.name).first().flatMap { _ in
            deck.user = try user.requireID()

            return deck.save(on: request)
                .map { deck in deck.toDbfIDJson() }
                .encode(status: .created, for: request)
        }
    }

    func getAllDecksHandler(_ request: Request) throws -> Future<[Deck.DbfIDJson]> {
        let user = try request.requireAuthenticated(User.self)
        return Deck.query(on: request)
            .filter(\.user == user.id)
            .all()
            .map { decks in
                decks.map { deck in return deck.toDbfIDJson() }
            }
    }

    func getDeckHandler(_ request: Request) throws -> Future<Deck.DbfIDJson> {
        let user = try request.requireAuthenticated(User.self)
        let id = try request.parameters.next(DeckIDParam.self)

        return Deck.find(id, on: request).map { deck in
            guard let deck = deck, try deck.user == user.requireID() else {
                throw Abort(.notFound, reason: "No deck found with id \(id)")
            }

            return deck.toDbfIDJson()
        }
    }

    func deleteDeckHandler(_ request: Request) throws -> Future<HTTPStatus> {
        let user = try request.requireAuthenticated(User.self)
        let id = try request.parameters.next(DeckIDParam.self)

        return Deck.find(id, on: request).flatMap { deck in
            guard let deck = deck, try deck.user == user.requireID() else {
                throw Abort(.notFound, reason: "No deck found with id \(id)")
            }

            return deck.delete(on: request).transform(to: HTTPStatus.noContent)
        }
    }

    func setCardsInDeckHandler(_ request: Request, cards: [DbfID]) throws -> Future<HTTPStatus> {
        let user = try request.requireAuthenticated(User.self)
        let id = try request.parameters.next(DeckIDParam.self)

        return Deck.find(id, on: request).flatMap { deck in
            guard var deck = deck, try deck.user == user.requireID() else {
                throw Abort(.notFound, reason: "No deck found with id \(id)")
            }

            try deck.setCards(cards)

            return deck.save(on: request).transform(to: HTTPStatus.noContent)
        }
    }
}
