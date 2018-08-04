//
//  Stats.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/3/18.
//

import Foundation

protocol CardStats {
    var dbfId: Int { get }
    var name: String { get }
    var cls: CardClass { get }
    var cost: Int { get }
}

protocol MinionStats: CardStats {
    var attack: Int { get }
    var health: Int { get }
}

protocol SpellStats: CardStats {
    
}

protocol WeaponStats: CardStats {
    var attack: Int { get }
    var durability: Int { get }
}

protocol EnchantmentStats: CardStats {
    
}

