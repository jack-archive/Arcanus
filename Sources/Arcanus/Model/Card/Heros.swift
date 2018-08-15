//
//  Heros.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/15/18.
//

import Foundation

struct HeroStatsConcrete: CardStats, HeroStats {
    var dbfId: DbfID
    var name: String
    var text: String = "Hero Card"
    var flavor: String = ""
    var cls: CardClass
    var collectible: Bool = false
    var rarity: CardRarity = .free
    var set: CardSet = .core
    var gang: GadgetzanGang? = nil
    var cost: Int = 0
    var mechanics: [CardMechanic] = []
    var playRequirements: PlayRequirements = [:]
    
    var health: Int = 30
    
    init(_ name: String, _ dbf: DbfID, _ cls: CardClass) {
        self.name = name
        self.dbfId = dbf
        self.cls = cls
    }
}

struct HeroPowerStatsConcrete: CardStats, HeroPowerStats {
    var dbfId: DbfID
    var name: String
    var text: String
    var flavor: String = ""
    var cls: CardClass
    var collectible: Bool = false
    var rarity: CardRarity = .free
    var set: CardSet = .core
    var gang: GadgetzanGang? = nil
    var cost: Int = 2
    var mechanics: [CardMechanic] = []
    var playRequirements: PlayRequirements = [:]
    
    init(_ name: String, _ text: String, _ dbf: DbfID, _ cls: CardClass) {
        self.name = name
        self.text = text
        self.dbfId = dbf
        self.cls = cls
    }
}

final class JainaProudmoore: Hero {
    static func stats() -> HeroStatsConcrete {
        return HeroStatsConcrete("Jaina Proudmoore", 637, .mage)
    }
    
    static private(set) var defaultCardStats: CardStats = stats()
    static private(set) var defaultHeroStats: HeroStats = stats()
    var cardStats: CardStats = stats()
    var heroStats: HeroStats = stats()
    
    var enchantments: [Enchantment] = []
}

final class Fireblast: HeroPower {
    static func stats() -> HeroPowerStatsConcrete {
        var rv = HeroPowerStatsConcrete("Fireblast", "<b>Hero Power</b>\nDeal $1 damage.", 807, .mage)
        rv.playRequirements[.targetToPlay] = 1
        return rv
    }
    
    static private(set) var defaultCardStats: CardStats = stats()
    static private(set) var defaultHeroPowerStats: HeroPowerStats = stats()
    var cardStats: CardStats = stats()
    var heroPowerStats: HeroPowerStats = stats()
    
    var enchantments: [Enchantment] = []
}

final class Thrall: Hero {
    static func stats() -> HeroStatsConcrete {
        return HeroStatsConcrete("Thrall", 1066, .shaman)
    }
    
    static private(set) var defaultCardStats: CardStats = stats()
    static private(set) var defaultHeroStats: HeroStats = stats()
    var cardStats: CardStats = stats()
    var heroStats: HeroStats = stats()
    
    var enchantments: [Enchantment] = []
}

final class TotemicCall: HeroPower {
    static func stats() -> HeroPowerStatsConcrete {
        var rv = HeroPowerStatsConcrete("Totemic Call", "<b>Hero Power</b>\nSummon a random Totem.", 687, .shaman)
        rv.playRequirements[.entireEntourageNotInPlay] = 0
        rv.playRequirements[.numMinionSlots] = 1
        return rv
    }
    
    static private(set) var defaultCardStats: CardStats = stats()
    static private(set) var defaultHeroPowerStats: HeroPowerStats = stats()
    var cardStats: CardStats = stats()
    var heroPowerStats: HeroPowerStats = stats()
    
    var enchantments: [Enchantment] = []
}
