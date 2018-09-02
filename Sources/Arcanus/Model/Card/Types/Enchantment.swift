//
//  Enchantment.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol Enchantment: Card {
    static var defaultEnchantmentStats: EnchantmentStats { get }
    var enchantmentStats: EnchantmentStats { get set }
}

extension CardStats where Self: EnchantmentStats {
    var cost: Int { return 0 }
}

extension Enchantment {
}

protocol EnchantmentStats: CardStats {
}

extension CardStats where Self: EnchantmentStats {
    var type: CardType { return .enchantment }
}
