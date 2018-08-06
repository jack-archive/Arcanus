// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Foundation
import Vapor
import VarInt

// https://hearthsim.info/docs/deckstrings/
// https://www.reddit.com/r/hearthstone/comments/6f2xyk/how_to_encodedecode_deck_codes/

enum Format: DbfID {
    case wild = 1
    case standard = 2
}

struct Deck: SQLiteModel, Content, Migration  {
    typealias ID = Int
    var id: ID?
    var format: Format
    var hero: Hero.Type
    var cards: [(count: Int, Card.Type)] // Count: Card
    
    enum CodingKeys: String, CodingKey {
        case array
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let array = try values.decode(Array<DbfID>.self, forKey: .array)
        try self.init(array: array)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.toArray(), forKey: .array)
    }
    
    init(array input: [DbfID]) throws {
        var array = input
        array.removeFirst() // First is always 0
        array.removeFirst() // Version still is always 1
        
        // Format
        guard let format = Format(rawValue: array.removeFirst()) else {
            throw Abort(.unprocessableEntity, reason: "Bad Format in array")
        }
        self.format = format
        
        // Hero
        guard array.removeFirst() == 1 else { throw Abort(.unprocessableEntity, reason: "Can only be one hero") }
        let heroID = array.removeFirst()
        guard let hero = getCard(dbfID: heroID) as? Hero.Type else {
            throw Abort(.unprocessableEntity, reason: "Can't find hero for \(heroID)")
        }
        self.hero = hero
        
        // Cards
        self.cards = []
        
        let oneCopyCardsCount = array.removeFirst()
        try array.dropLast(array.count - oneCopyCardsCount) // Get one copy card sub array
            .map({ card in try getCard(dbfID: card)         // Get card type for DbfID, check for nil
                .unwrap(or: Abort(.unprocessableEntity, reason: "Could not find card \(card)")) })
            .forEach({ self.cards.append((1, $0)) })        // Add to self.cards
        array.removeFirst(oneCopyCardsCount)                // Move array ahead
        
        let twoCopyCardsCount = array.removeFirst()
        try array.dropLast(array.count - twoCopyCardsCount)
            .map({ card in try getCard(dbfID: card)
                .unwrap(or: Abort(.unprocessableEntity, reason: "Could not find card \(card)")) })
            .forEach({ self.cards.append((2, $0)) })
        array.removeFirst(twoCopyCardsCount)
        
        let nCopyCardsCount = array.removeFirst()
        try array.dropLast(array.count - nCopyCardsCount).toNCopyPairs()
            .map({ pair in try getCard(dbfID: pair.card)
                .unwrap(or: Abort(.unprocessableEntity, reason: "Could not find card \(pair.card)")) })
            .forEach({ self.cards.append((1, $0)) })
        array.removeFirst(nCopyCardsCount)
        
        if !array.isEmpty {
            throw Abort(.unprocessableEntity, reason: "Extra bytes in array, Corrupt format")
        }
    }
    
    func toArray() -> [DbfID] {
        var rv: [DbfID] = []
        rv.append(0) // Always 0
        rv.append(1) // Version 1
        rv.append(format.rawValue)
        
        rv.append(1) // One hero
        rv.append(hero.defaultCardStats.dbfId)
        
        let oneCopyCards = self.cards.filter({ $0.count == 1 })
        rv.append(oneCopyCards.count)
        oneCopyCards.forEach { _, card in
            rv.append(card.defaultCardStats.dbfId)
        }
        
        let twoCopyCards = self.cards.filter({ $0.count == 2 })
        rv.append(twoCopyCards.count)
        twoCopyCards.forEach { _, card in
            rv.append(card.defaultCardStats.dbfId)
        }
        
        let nCopyCards = self.cards.filter({ $0.count > 2 })
        rv.append(nCopyCards.count)
        nCopyCards.forEach { count, card in
            rv.append(card.defaultCardStats.dbfId)  // First is DbfID
            rv.append(count)                        // Second is count
        }
        
        return rv
    }
    
    func deckstring() -> String {
        return encodeDeckstring(self.toArray().map({ UInt64($0) }))
    }
}

// MARK: n-Copy Pair Extensions

fileprivate struct NCopyPair {
    var card: DbfID
    var count: Int
}

fileprivate func toNCopyPairs(_ self: Array<DbfID>) throws -> [NCopyPair] {
    return try self.toPairs()
        .unwrap(or: Abort(.unprocessableEntity, reason: "n-Copy array not divisible by 2"))
        .map { return NCopyPair(card: $0, count: $1) }
}

fileprivate extension ArraySlice where Element == DbfID {
    func toNCopyPairs() throws -> [NCopyPair] {
        let copy = Array(self)
        return try Arcanus.toNCopyPairs(copy)
    }
}

fileprivate extension Array where Element == DbfID {
    func toNCopyPairs() throws -> [NCopyPair] {
        return try Arcanus.toNCopyPairs(self)
    }
}

// MARK: Deckstring

enum DeckstringError: Error {
    case base64DecodeFailed
}

// See https://www.reddit.com/r/hearthstone/comments/6f2xyk/how_to_encodedecode_deck_codes/
// for info on how the encoding works
func decodeDeckstring(_ input: String) throws -> [UInt64] {
    guard var data = Data(base64Encoded: input) else {
        throw DeckstringError.base64DecodeFailed
    }
    
    // Setup bytes to hold data
    var bytes: [UInt8] = Array(repeating: 0, count: data.count)
    data.copyBytes(to: UnsafeMutablePointer(&bytes), count: data.count)
    var ints: [UInt64] = []
    
    while true {
        let (int, count) = uVarInt(bytes)
        if count <= 0 {
            break
        }
        ints.append(int)
        bytes.removeFirst(count)
    }
    
    return ints
}

fileprivate func encodeDeckstring(_ input: [UInt64]) -> String {
    var bytes: [UInt8] = []
    for val in input {
        bytes.append(contentsOf: putUVarInt(val))
    }
    
    return Data(bytes: bytes).base64EncodedString()
}

