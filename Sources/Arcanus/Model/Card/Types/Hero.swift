//
//  Hero.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol Hero: Card {
    static var defaultHeroStats: HeroStats { get }
    var heroStats: HeroStats { get set }
}

extension Hero {
    static var health: Int { return defaultHeroStats.health }
    
    var health: Int {
        get { return self.heroStats.health }
        set { self.heroStats.health = newValue }
    }
}

protocol HeroStats: CardStats {
    var health: Int { get set }
}

extension CardStats where Self: HeroStats {
    var type: CardType { return .hero }
}
