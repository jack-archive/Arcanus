// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum CardClass: String, Codable {
    case neutral = "NEUTRAL"
    case druid = "DRUID"
    case hunter = "HUNTER"
    case mage = "MAGE"
    case paladin = "PALADIN"
    case priest = "PRIEST"
    case rouge = "ROUGE"
    case shaman = "SHAMAN"
    case warlock = "WARLOCK"
    case warrior = "WARRIOR"
}

enum CardType: String, Codable {
    case minion = "MINION"
    case spell = "SPELL"
    case weapon = "WEAPON"
    case hero = "HERO"
}

enum CardRarity: String, Codable {
    case free = "FREE"
    case common = "COMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"
}

enum CardSet: String, Codable {
    case core = "CORE"
    case classic = "EXPERT1"
    case hof = "HOF" // Hall of Fame
}

enum PlayRequirement: String, Codable {
    case minionTarget = "REQ_MINION_TARGET"
    case targetIfAvaliable = "REQ_TARGET_IF_AVAILABLE"
    case targetToPlay = "REQ_TARGET_TO_PLAY"
    case entireEntourageNotInPlay = "REQ_ENTIRE_ENTOURAGE_NOT_IN_PLAY"
    case numMinionSlots = "REQ_NUM_MINION_SLOTS"
}

enum CardMechanic: String, Codable {
    case charge = "STEALTH"
    case taunt = "TAUNT"
}

enum MinionRace: String, Codable {
    case beast = "BEAST"
    case dragon = "DRAGON"
    case demon = "DEMON"
    case pirate = "PIRATE"
    case totem = "TOTEM"
    case murloc = "MURLOC"
    case elemental = "ELEMENTAL"
    case mech = "MECHANICAL"
    case all = "ALL"
    case orc = "ORC"
}
