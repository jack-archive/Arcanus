// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

protocol Stats: Codable {
}

fileprivate enum CodingKeys: CodingKey {
    case dbfId
    case name
    case text
    case flavor
    case cls
    case collectible
    case type
    case rarity
    case set
    case gang
    case cost
    case mechanics
    case playRequirements
    
    case attack
    case health
    case durability
    case race
}

protocol CardStats: Stats {
    var dbfId: DbfID { get }
    var name: String { get set }
    var text: String { get set }
    var flavor: String { get }
    var cls: CardClass { get set }
    var collectible: Bool { get }
    var type: CardType { get }
    var rarity: CardRarity { get }
    var set: CardSet { get }
    var gang: GadgetzanGang? { get }
    var cost: Int { get set }
    var mechanics: [CardMechanic] { get set }
    var playRequirements: PlayRequirements { get set }
}

protocol MinionStats: Stats {
    var attack: Int { get set }
    var health: Int { get set }
    var race: MinionRace { get }
}

extension CardStats where Self: MinionStats {
    var type: CardType { return .minion }
}

protocol SpellStats: Stats {
}

extension CardStats where Self: SpellStats {
    var type: CardType { return .spell }
}

protocol WeaponStats: Stats {
    var attack: Int { get set }
    var durability: Int { get set }
}

extension CardStats where Self: WeaponStats {
    var type: CardType { return .weapon }
}

protocol EnchantmentStats: Stats {
}

extension CardStats where Self: EnchantmentStats {
    var type: CardType { return .enchantment }
}

protocol HeroStats: Stats {
    var health: Int { get set }
}

extension CardStats where Self: HeroStats {
    var type: CardType { return .hero }
}

protocol HeroPowerStats: Stats {
}

extension CardStats where Self: HeroPowerStats {
    var type: CardType { return .power }
}

struct StatsContainer: Content {
    var stats: CardStats

    init(from decoder: Decoder) throws {
        throw Abort(.badRequest, reason: "Not Decodable")
    }

    init(stats: CardStats) {
        self.stats = stats
    }

    func encode(to encoder: Encoder) throws {
        try self.stats.encode(to: encoder)
    }
}
