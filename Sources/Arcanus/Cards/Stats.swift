//
//  Stats.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/3/18.
//

import Foundation

protocol CardStats {
    var dbfId: Int { get set }
    var name: String { get set }
    var cls: CardClass { get set }
    var cost: Int { get set }
    var mechanics: [CardMechanic] { get set }

}

protocol MinionStats {
    var attack: Int { get set }
    var health: Int { get set }
}

protocol SpellStats {
    
}

protocol WeaponStats {
    var attack: Int { get }
    var durability: Int { get }
}

protocol EnchantmentStats {
    
}

