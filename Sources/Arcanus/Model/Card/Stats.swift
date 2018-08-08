// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

protocol Stats: Codable {
    
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

protocol MinionStats: Stats {
    var attack: Int { get set }
    var health: Int { get set }
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
    var minion: MinionStats?
    var spell: SpellStats?
    var weapon: WeaponStats?
    var enchantment: EnchantmentStats?
    var hero: HeroStats?
    var hp: HeroPowerStats?
    
    enum CodingKeys: CodingKey {
        case dbfId
        case name
        case text
        case cls
        case cost
        case mechanics
        
        case attack
        case health
        case durability
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        stats.dbfId = try values.decode(DbfID.self, forKey: .dbfId)
        stats.name = try values.decode(String.self, forKey: .name)
        stats.text = try values.decode(String.self, forKey: .text)
        stats.cls = try values.decode(CardClass.self, forKey: .cls)
        stats.cost = try values.decode(Int.self, forKey: .cost)
        stats.mechanics = try values.decode([CardMechanic].self, forKey: .mechanics)

        
        

    }
}
