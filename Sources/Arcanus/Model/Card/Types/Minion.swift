//
//  Minion.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

protocol Minion: Card {
    static var defaultMinionStats: MinionStats { get }
    var minionStats: MinionStats { get set }
}

extension Minion {
    static var attack: Int { return defaultMinionStats.attack }
    static var health: Int { return defaultMinionStats.health }
    static var race: MinionRace { return defaultMinionStats.race }
    
    var attack: Int {
        get { return self.minionStats.attack }
        set { self.minionStats.attack = newValue }
    }
    
    var health: Int {
        get { return self.minionStats.health }
        set { self.minionStats.health = newValue }
    }
    
    var race: MinionRace { return minionStats.race }
}

protocol MinionStats: CardStats {
    var attack: Int { get set }
    var health: Int { get set }
    var race: MinionRace { get }
}

extension CardStats where Self: MinionStats {
    var type: CardType { return .minion }
}
