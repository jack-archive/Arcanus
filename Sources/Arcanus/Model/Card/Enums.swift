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
    case basic, classic
}

// http://hearthstone.wikia.com/wiki/Race
enum CardRace: String, Codable {
    case neutral
}

enum CardClass: String, Codable {
    case neutral
    case druid, hunter, mage,
    paladin, priest, rouge,
    shaman, warlock, warrior
}

enum CardMechanic: String, Codable {
    case charge, taunt, windfury, battlecry, deathrattle
    case oneTurnEffect
}
