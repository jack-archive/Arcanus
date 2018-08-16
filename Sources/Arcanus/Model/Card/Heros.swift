// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
    var gang: GadgetzanGang?
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
    var gang: GadgetzanGang?
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

    private(set) static var defaultCardStats: CardStats = stats()
    private(set) static var defaultHeroStats: HeroStats = stats()
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

    private(set) static var defaultCardStats: CardStats = stats()
    private(set) static var defaultHeroPowerStats: HeroPowerStats = stats()
    var cardStats: CardStats = stats()
    var heroPowerStats: HeroPowerStats = stats()

    var enchantments: [Enchantment] = []
}

final class Thrall: Hero {
    static func stats() -> HeroStatsConcrete {
        return HeroStatsConcrete("Thrall", 1066, .shaman)
    }

    private(set) static var defaultCardStats: CardStats = stats()
    private(set) static var defaultHeroStats: HeroStats = stats()
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

    private(set) static var defaultCardStats: CardStats = stats()
    private(set) static var defaultHeroPowerStats: HeroPowerStats = stats()
    var cardStats: CardStats = stats()
    var heroPowerStats: HeroPowerStats = stats()

    var enchantments: [Enchantment] = []
}
