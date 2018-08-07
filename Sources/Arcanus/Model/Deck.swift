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

// https://www.reddit.com/r/hearthstone/comments/6f2xyk/how_to_encodedecode_deck_codes/
// https://hearthsim.info/docs/deckstrings/
/*
 
 2. Cards block
 The cards block is split in four pairs of length + array in the following order:
 
 - Heroes
 - Single-copy cards
 - 2-copy cards
 - n-copy cards
 
 Each pair has a leading varint specifying the number of items in the array. For the first three blocks, those are arrays of varints. For the last block, it is an array of pairs of varints. The goal of this structure is to make the deckstring as compact as possible. Each card is represented with a varint DBF ID as mentioned before.
 
 Heroes: An array of initial heroes present in the deck. In other words, which hero the deck was made for. You should really always expect one. Additional note: The hero’s class determines which class the deck is for, but the deck is ostensibly made for a hero, not a class. If the specified hero is a hero skin, it will be used instead of the main hero iff available.
 
 Note on heroes: Although it is an array, it is used for the initial hero, not playable heroes (such as the Frozen Throne heroes). If you can draw it, do not use this array.
 
 Single-copy cards: Cards for which there is exactly one copy in the deck. 2-copy cards: Cards for which there is exactly two copies in the deck.
 
 n-copy cards: All other cards in the deck. This array is a list of varint pairs, **representing first the dbf id, followed by the amount of times that card is present in the deck**. This SHOULD only contain cards with a minimum of 3 instances in the deck, which means that it will (at this time) always be empty for constructed decks; however it can theoretically contain single and double copy cards as well.
 
 Although final ordering does not matter, cards are sorted by DBF ID in their respective array in order to consistently generate the same deckstrings for the same decks.
 
 */

// Frequency Representation: 30 cards, each specified number of times, i.e. 2 cards means repeat dbfID twice
// Deckstring Representation: 3 sparate arrays, 3rd one is n-copy array

enum Format: DbfID {
    case wild = 1
    case standard = 2
}

struct DbfIDDeckJson: Content {
    var format: Int
    var hero: DbfID
    var cards: [DbfID] // Frequency
}

struct NameDeckJson: Content {
    var format: Int
    var hero: String
    var cards: [String] // Frequency
}

struct Deck: SQLiteModel, Migration  {
    typealias ID = Int
    var id: ID?
    var format: Format
    var hero: Hero.Type
    // Stored in Freq representation
    var cards: [Card.Type]
    
    enum CodingKeys: String, CodingKey {
        case id
        case format
        case hero
        case cards
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(ID?.self, forKey: .id)
        let format = try values.decode(Int.self, forKey: .format)
        let hero = try values.decode(DbfID.self, forKey: .hero)
        let cards = try values.decode(Array<DbfID>.self, forKey: .cards)
        
        try self.init(id: id, format: format, hero: hero, cards: cards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.format.rawValue, forKey: .format)
        try container.encode(self.hero.defaultCardStats.dbfId, forKey: .hero)
        try container.encode(self.toDbfIDArray(), forKey: .cards)
    }
    
    func toDbfIDArray() -> [DbfID] {
        return self.cards.map({ $0.defaultCardStats.dbfId })
    }
    
    init(id: ID? = nil, format: Format, hero: Hero.Type, cards: [DbfID]) throws {
        self.id = id
        self.format = format
        self.hero = hero
        self.cards = try cards.map({ try CardIndex.get(Card.self, $0).unwrap(or: Abort(.badRequest)) })
    }
    
    init(id: ID? = nil, format raw: Int, hero dbfId: DbfID, cards: [DbfID]) throws {
        guard let format = Format(rawValue: raw) else {
            throw Abort(.badRequest)
        }
        
        guard let hero = getCard(dbfID: dbfId) as? Hero.Type else {
            throw Abort(.unprocessableEntity)
        }
        
        try self.init(id: id, format: format, hero: hero, cards: cards)
    }
    
    func deckstringToFrequency(copy: Int? = nil /* 1, 2, or nil for n-copy array */,
        array: [DbfID]) throws -> [DbfID] {
        var rv: [DbfID] = []
        
        if copy != nil { // 1 or 2 copy
            array.forEach { dbfId in
                rv.append(contentsOf: Array(repeating: dbfId, count: copy!))
            }
        } else { // n-Copy
            let pairs = try array.toNCopyPairs()
            pairs.forEach { pair in
                rv.append(contentsOf: Array(repeating: pair.card, count: pair.count))
            }
        }
        
        return rv
    }
    
    init(fromJson json: DbfIDDeckJson) throws {
        try self.init(format: json.format, hero: json.hero, cards: json.cards)
    }
    
    init(fromDeckstring input: String) throws {
        let arr = try decodeDeckstring(input).map({ DbfID($0) })
        try self.init(fromDeckstring: arr)
    }
    
    func parseDeckstringArrayToCards(copy: Int?, _ array: inout [DbfID]) throws -> [Card.Type] {
        let count = array.removeFirst()
        let deckstring = Array(array.prefix(count))
        array.removeFirst(count)
        let freq = try deckstringToFrequency(copy: copy, array: deckstring)
        return try freq.map({ try getCard(dbfID: $0).unwrap(or: Abort(.badRequest)) })
    }
    
    init(fromDeckstring input: [DbfID]) throws {
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
        self.cards.append(contentsOf: try parseDeckstringArrayToCards(copy: 1, &array))
        self.cards.append(contentsOf: try parseDeckstringArrayToCards(copy: 2, &array))
        self.cards.append(contentsOf: try parseDeckstringArrayToCards(copy: nil, &array))
        
        // Check that array is not malformed
        if !array.isEmpty {
            throw Abort(.unprocessableEntity, reason: "Extra bytes in array, Corrupt format")
        }
    }
    
    func countCards() -> [DbfID: Int] {
        var dict: [DbfID: Int] = [:]
        for card in self.toDbfIDArray() {
            if dict[card] != nil {
                dict[card]! += 1
            } else {
                dict[card] = 1
            }
        }
        return dict
    }
    
    func makeDeckstringCardArray(copy: Int?, counts: [DbfID: Int]) -> [DbfID] {
        var rv: [DbfID] = []
        rv.append(counts.count)
        counts.forEach { card, count in
            rv.append(card) // Add card regardless
            if copy == nil {
                rv.append(count)
            }
        }
        
        return rv
    }
    
    /// Encoded as deckstring, with format, hero array, and 3 card arrays
    func toDeckstringArray() -> [DbfID] {
        var rv: [DbfID] = []
        rv.append(0) // Always 0
        rv.append(1) // Version 1
        rv.append(format.rawValue)
        
        rv.append(1) // One hero
        rv.append(hero.defaultCardStats.dbfId)
        
        let counts = self.countCards()
        let oneCopyCards = counts.filter { _, count in return count == 1 }
        let twoCopyCards = counts.filter { _, count in return count == 2 }
        let nCopyCards = counts.filter { _, count in return count > 2 }
        
        rv.append(contentsOf: makeDeckstringCardArray(copy: 1, counts: oneCopyCards))
        rv.append(contentsOf: makeDeckstringCardArray(copy: 2, counts: twoCopyCards))
        rv.append(contentsOf: makeDeckstringCardArray(copy: nil, counts: nCopyCards))
        
        return rv
    }
    
    func deckstring() -> String {
        return encodeDeckstring(self.toDeckstringArray().map({ UInt64($0) }))
    }
}

// MARK: n-Copy Pair Extensions

fileprivate typealias NCopyPairDbfID = (card: DbfID, count: Int)

fileprivate func toNCopyPairs(_ self: Array<DbfID>) throws -> [NCopyPairDbfID] {
    return try self.toPairs()
        .unwrap(or: Abort(.unprocessableEntity, reason: "n-Copy array not divisible by 2"))
        .map { return NCopyPairDbfID(card: $0, count: $1) }
}

fileprivate extension Array where Element == DbfID {
    func toNCopyPairs() throws -> [NCopyPairDbfID] {
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

func encodeDeckstring(_ input: [UInt64]) -> String {
    var bytes: [UInt8] = []
    for val in input {
        bytes.append(contentsOf: putUVarInt(val))
    }
    
    return Data(bytes: bytes).base64EncodedString()
}

