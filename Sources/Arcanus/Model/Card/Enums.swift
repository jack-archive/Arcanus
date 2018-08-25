// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension RawRepresentable where RawValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

enum CardType: String, Codable {
    case minion, spell, weapon, enchantment, hero, power
}

enum CardRarity: String, Codable {
    case free, common, rare, epic, legendary
}

enum CardSet: String, Codable {
    case core, classic, hof
    case naxx, gvg, brm, tgt, loe, gods, karazhan, gadgetzan
    case ungoro, knights, kobolds, witchwood, boomsday
}

enum GadgetzanGang: String, Codable {
    case kabal, goons, lotus
}

enum PlayRequirement: String, Codable {
    case minionTarget
    case targetIfAvaliable
    case targetToPlay
    case entireEntourageNotInPlay
    case numMinionSlots
}

typealias PlayRequirements = [PlayRequirement: Int]

// http://hearthstone.wikia.com/wiki/Race
enum MinionRace: String, Codable {
    case neutral
    case murloc, demon, mech, elemental,
        beast, totem, pirate, dragon, all
}

enum CardClass: String, Codable {
    case neutral
    case druid, hunter, mage,
        paladin, priest, rouge,
        shaman, warlock, warrior
}

enum CardMechanic: String, Codable {
    case charge, taunt, stealth, windfury, battlecry, deathrattle
    case oneTurnEffect
}

struct AllowedCards {
    var sets: [CardSet]
    var allowed: [DbfID]
    var unallowed: [DbfID]

    enum CodingKeys: CodingKey {
        case sets
        case allowed
        case unallowed
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.sets = try values.decode([String].self, forKey: .sets)
            .map({ CardSet(rawValue: $0) })
            .compactMap({ $0 }) // Unwrap
        self.allowed = try values.decode([DbfID].self, forKey: .allowed)
        self.unallowed = try values.decode([DbfID].self, forKey: .unallowed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sets.map({ $0.rawValue }), forKey: .sets)
        try container.encode(self.allowed, forKey: .allowed)
        try container.encode(self.unallowed, forKey: .unallowed)
    }

    func isAllowed(_ card: Card.Type) -> Bool {
        // return card.defaultCardStats
        return false
    }
}
