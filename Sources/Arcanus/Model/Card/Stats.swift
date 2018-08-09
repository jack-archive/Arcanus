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
    case cls
    case type
    case cost
    case mechanics
    
    case attack
    case health
    case durability
}

protocol CardStats: Stats {
    var dbfId: DbfID { get set }
    var name: String { get set }
    var text: String { get set }
    var cls: CardClass { get set }
    var type: CardType { get }
    var cost: Int { get set }
    var mechanics: [CardMechanic] { get set }
}

extension CardStats {
    fileprivate func encodeCardStats(to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encode(self.dbfId, forKey: .dbfId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.cls, forKey: .cls)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.cost, forKey: .cost)
        try container.encode(self.mechanics, forKey: .mechanics)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
    }
}

protocol MinionStats: Stats {
    var attack: Int { get set }
    var health: Int { get set }
}

extension CardStats where Self: MinionStats {
    var type: CardType { return .minion }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
        try container.encode(self.attack, forKey: .attack)
        try container.encode(self.health, forKey: .health)
    }
}

protocol SpellStats: Stats {
}

extension CardStats where Self: SpellStats {
    var type: CardType { return .spell }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
    }
}

protocol WeaponStats: Stats {
    var attack: Int { get set }
    var durability: Int { get set }
}

extension CardStats where Self: WeaponStats {
    var type: CardType { return .weapon }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
        try container.encode(self.attack, forKey: .attack)
        try container.encode(self.durability, forKey: .durability)
    }
}

protocol EnchantmentStats: Stats {
}

extension CardStats where Self: EnchantmentStats {
    var type: CardType { return .enchantment }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
    }
}

protocol HeroStats: Stats {
    var health: Int { get set }
}

extension CardStats where Self: HeroStats {
    var type: CardType { return .hero }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
        try container.encode(self.health, forKey: .health)
    }
}

protocol HeroPowerStats: Stats {
}

extension CardStats where Self: HeroPowerStats {
    var type: CardType { return .power }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.encodeCardStats(to: &container)
    }
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

