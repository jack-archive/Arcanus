//
//  Power.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol HeroPower: Card {
    static var defaultHeroPowerStats: HeroPowerStats { get }
    var heroPowerStats: HeroPowerStats { get set }
}

extension HeroPower {
}

protocol HeroPowerStats: CardStats {
}

extension CardStats where Self: HeroPowerStats {
    var type: CardType { return .power }
}
