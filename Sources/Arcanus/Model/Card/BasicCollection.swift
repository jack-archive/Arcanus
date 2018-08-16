// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

// Murloc Tidehunter
// Kobold Geomancer
// Frostwolf Warlord
// Stormwind Champion

func addBasicCollection() {
    CardIndex.add(Placeholder.self)
    CardIndex.add(SenjinShieldmasta.self)
    CardIndex.add(JainaProudmoore.self)
    CardIndex.add(Fireblast.self)
}

final class Placeholder: Card, Minion, Spell, Weapon, Enchantment, Hero, HeroPower {
    struct Stats: CardStats, MinionStats, SpellStats, WeaponStats, EnchantmentStats, HeroStats, HeroPowerStats {
        var dbfId: DbfID = 1
        var name: String = "Placeholder"
        var text: String = "PLACEHOLDER CARD"
        var flavor: String = ""
        var cls: CardClass = .neutral
        var collectible: Bool = true
        var type: CardType = .minion
        var rarity: CardRarity = .free
        var set: CardSet = .core
        var gang: GadgetzanGang?
        var cost: Int = 1
        var mechanics: [CardMechanic] = []
        var playRequirements: PlayRequirements = [:]

        var attack: Int = 1
        var health: Int = 1
        var durability: Int = 1
        var race: MinionRace = .neutral
    }

    private(set) static var defaultMinionStats: MinionStats = Stats()
    var minionStats: MinionStats = Stats()
    private(set) static var defaultSpellStats: SpellStats = Stats()
    var spellStats: SpellStats = Stats()
    private(set) static var defaultWeaponStats: WeaponStats = Stats()
    var weaponStats: WeaponStats = Stats()
    private(set) static var defaultEnchantmentStats: EnchantmentStats = Stats()
    var enchantmentStats: EnchantmentStats = Stats()
    private(set) static var defaultHeroStats: HeroStats = Stats()
    var heroStats: HeroStats = Stats()
    private(set) static var defaultHeroPowerStats: HeroPowerStats = Stats()
    var heroPowerStats: HeroPowerStats = Stats()
    private(set) static var defaultCardStats: CardStats = Stats()
    var cardStats: CardStats = Stats()

    var enchantments: [Enchantment] = []
}

final class SenjinShieldmasta: Minion {
    struct Stats: CardStats, MinionStats {
        var dbfId: DbfID = 635
        var name: String = "Sen'jin Shieldmasta"
        var text: String = "<b>Taunt</b>"
        var flavor: String = "Sen'jin Village is nice, if you like trolls and dust."
        var cls: CardClass = .neutral
        var collectible: Bool = true
        var type: CardType = .minion
        var rarity: CardRarity = .free
        var set: CardSet = .core
        var gang: GadgetzanGang?
        var cost: Int = 4
        var mechanics: [CardMechanic] = [.taunt]
        var playRequirements: PlayRequirements = [:]
        var attack: Int = 3
        var health: Int = 5
        var race: MinionRace = .neutral
    }

    private(set) static var defaultCardStats: CardStats = Stats()
    private(set) static var defaultMinionStats: MinionStats = Stats()
    var cardStats: CardStats = Stats()
    var minionStats: MinionStats = Stats()

    var enchantments: [Enchantment] = []
}

final class BloodfenRaptor: Minion {
    struct Stats: CardStats, MinionStats {
        var dbfId: DbfID = 216
        var name: String = "Bloodfen Raptor"
        var text: String = ""
        var flavor: String = "\"Kill 30 raptors.\" - Hemet Nesingwary"
        var cls: CardClass = .neutral
        var collectible: Bool = true
        var type: CardType = .minion
        var rarity: CardRarity = .free
        var set: CardSet = .core
        var gang: GadgetzanGang?
        var cost: Int = 2
        var mechanics: [CardMechanic] = [.taunt]
        var playRequirements: PlayRequirements = [:]
        var attack: Int = 3
        var health: Int = 2
        var race: MinionRace = .beast
    }

    private(set) static var defaultCardStats: CardStats = Stats()
    private(set) static var defaultMinionStats: MinionStats = Stats()
    var cardStats: CardStats = Stats()
    var minionStats: MinionStats = Stats()

    var enchantments: [Enchantment] = []
}
