// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

final class SenjinShieldmasta: Minion {
    struct Stats: CardStats, MinionStats {
        var dbfId: DbfID = 635
        var name: String = "Sen'jin Shieldmasta"
        var text: String = "<b>Taunt</b>"
        var cls: CardClass = .neutral
        var cost: Int = 4
        var mechanics: [CardMechanic] = [.taunt]
        var attack: Int = 3
        var health: Int = 5
    }

    static var defaultCardStats: CardStats { return Stats() }
    static var defaultMinionStats: MinionStats { return Stats() }
    var cardStats: CardStats = Stats()
    var minionStats: MinionStats = Stats()

    var enchantments: [Enchantment] = []
}

final class AbusiveSergeant: Minion {
    struct Stats: CardStats, MinionStats {
        var dbfId: DbfID = 242
        var name: String = "Abusive Sergeant"
        var text: String = "<b>Battlecry:</b> Give a minion +2 Attack this turn."
        var cls: CardClass = .neutral
        var cost: Int = 1
        var mechanics: [CardMechanic] = [.battlecry]
        var attack: Int = 1
        var health: Int = 1
    }

    static var defaultCardStats: CardStats { return Stats() }
    static var defaultMinionStats: MinionStats { return Stats() }
    var cardStats: CardStats = Stats()
    var minionStats: MinionStats = Stats()

    var enchantments: [Enchantment] = []
}

/// Abusive Sergeant gives this enchantment
final class Inspired: Enchantment {
    struct Stats: CardStats, EnchantmentStats {
        var dbfId: DbfID = 809
        var name: String = "Inspired"
        var text: String = "This minion has +2 Attack this turn."
        var cls: CardClass = .neutral
        var cost: Int = 0
        var mechanics: [CardMechanic] = [.oneTurnEffect]
    }

    static var defaultCardStats: CardStats { return Stats() }
    static var defaultEnchantmentStats: EnchantmentStats { return Stats() }
    var cardStats: CardStats = Stats()
    var enchantmentStats: EnchantmentStats = Stats()

    var enchantments: [Enchantment] = []
}

final class JainaProudmoore: Hero {
    struct Stats: CardStats, HeroStats {
        var dbfId: DbfID = 637
        var name: String = "Jaina Proudmoore"
        var text: String = ""
        var cls: CardClass = .mage
        var cost: Int = 0
        var mechanics: [CardMechanic] = []
        var health: Int = 30
    }

    static var defaultCardStats: CardStats { return Stats() }
    static var defaultHeroStats: HeroStats { return Stats() }
    var cardStats: CardStats = Stats()
    var heroStats: HeroStats = Stats()

    var enchantments: [Enchantment] = []
}

final class Fireblast: HeroPower {
    struct Stats: CardStats, HeroPowerStats {
        var dbfId: DbfID = 807
        var name: String = "Fireblast"
        var text: String = "<b>Hero Power</b>\nDeal $1 damage."
        var cls: CardClass = .mage
        var cost: Int = 0
        var mechanics: [CardMechanic] = []
    }

    static var defaultCardStats: CardStats { return Stats() }
    static var defaultHeroPowerStats: HeroPowerStats { return Stats() }
    var cardStats: CardStats = Stats()
    var heroPowerStats: HeroPowerStats = Stats()

    var enchantments: [Enchantment] = []
}
