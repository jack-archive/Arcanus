//
//  DeckConvertible.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/19/18.
//

import Foundation
import Vapor

protocol DeckConvertible {
    func asDeck() throws -> Deck
}

extension Deck {
    static func fromRequest(_ request: Request) throws -> Deck {
        let dbfIdJson = try? request.content.syncDecode(Deck.DbfIDJson.self)
        let nameJson = try? request.content.syncDecode(Deck.NameJson.self)
        let deckstringJson = try? request.content.syncDecode(Deck.DeckstringJson.self)

        if let dbfIdJson = dbfIdJson {
            return try dbfIdJson.asDeck()
        } else if let nameJson = nameJson {
            return try nameJson.asDeck()
        } else if let deckstringJson = deckstringJson {
            return try deckstringJson.asDeck()
        } else {
            throw Abort(.badRequest, reason: "JSON does not match required format")
        }
    }
}

extension Deck {
    struct DbfIDJson: Content, DeckConvertible {
        var id: Deck.ID?
        var name: String?
        var format: Int
        var hero: DbfID
        var cards: [DbfID] // Frequency

        init(id: Deck.ID? = nil, name: String? = nil, format: Int, hero: DbfID, cards: [DbfID]) {
            self.id = id
            self.name = name
            self.format = format
            self.hero = hero
            self.cards = cards
        }

        func asDeck() throws -> Deck {
            return try Deck(fromJson: self)
        }
    }

    struct NameJson: Content, DeckConvertible {
        var id: Deck.ID?
        var name: String?
        var format: Int
        var hero: String
        var cards: [String] // Frequency

        init(id: Deck.ID? = nil, name: String? = nil, format: Int, hero: String, cards: [String]) {
            self.id = id
            self.name = name
            self.format = format
            self.hero = hero
            self.cards = cards
        }

        func asDeck() throws -> Deck {
            return try Deck(fromJson: self)
        }
    }

    struct DeckstringJson: Content, DeckConvertible {
        var id: Deck.ID?
        var name: String?
        var deckstring: String

        init(id: Deck.ID? = nil, name: String? = nil, deckstring: String) {
            self.id = id
            self.name = name
            self.deckstring = deckstring
        }

        func asDeck() throws -> Deck {
            return try Deck(fromJson: self)
        }
    }

    func toDbfIDJson() -> DbfIDJson {
        return DbfIDJson(id: self.id,
                         name: self.name,
                         format: self.format.rawValue,
                         hero: self.hero.dbfId,
                         cards: self.cards.map({ $0.dbfId }))
    }

    func toNameJson() -> NameJson {
        return NameJson(id: self.id,
                        name: self.name,
                        format: self.format.rawValue,
                        hero: self.hero.name,
                        cards: self.cards.map({ $0.name }))
    }

    func toDeckstringJson() -> DeckstringJson {
        return DeckstringJson(id: self.id,
                              name: self.name,
                              deckstring: self.deckstring())
    }
}
