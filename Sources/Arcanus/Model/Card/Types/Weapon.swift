//
//  Weapon.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol Weapon: Card {
    static var defaultWeaponStats: WeaponStats { get }
    var weaponStats: WeaponStats { get set }
}

extension Weapon {
    static var attack: Int { return defaultWeaponStats.attack }
    static var durability: Int { return defaultWeaponStats.durability }
    
    var attack: Int {
        get { return self.weaponStats.attack }
        set { self.weaponStats.attack = newValue }
    }
    
    var durability: Int {
        get { return self.weaponStats.durability }
        set { self.weaponStats.durability = newValue }
    }
}

protocol WeaponStats: CardStats {
    var attack: Int { get set }
    var durability: Int { get set }
}

extension CardStats where Self: WeaponStats {
    var type: CardType { return .weapon }
}

