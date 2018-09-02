//
//  Spell.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol Spell: Card {
    static var defaultSpellStats: SpellStats { get }
    var spellStats: SpellStats { get set }
}

protocol SpellStats: CardStats {
}

extension CardStats where Self: SpellStats {
    var type: CardType { return .spell }
}
