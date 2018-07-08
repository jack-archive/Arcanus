// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class Card {
    public static func makeNameClassReady(_ name: String) -> String {
        return name.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "'", with: "")
    }

    public static func classForName(_ name: String) -> Card.Type? {
        let readyName = makeNameClassReady(name)
        return NSClassFromString("\(namespaceAsString()).\(readyName)") as? Card.Type
    }

    public enum Class: String {
        case neutral
        case druid
        case hunter
        case mage
        case paladin
        case priest
        case rouge
        case shaman
        case warlock
        case warrior
    }

    public enum CardType: String {
        case minion
        case spell
        case weapon
        case enchantment
    }

    public enum Mechanics: String {
        case charge
        case taunt
        case windfury
        case battlecry
        case deathrattle
    }

    var id: String
    var dbfId: Int
    public var name: String
    var cardClass: Class
    var cardType: CardType
    var cost: Int

    /*
    public init() {
        log.error("Shouldn't use Card.init(), implement subclass, or use other initializer")
        fatalError("Should not be an instance of Card created with this")
    }
    */

    public init(_ id: String, _ dbfId: Int, _ name: String, _ cardClass: Class, _ cardType: CardType, _ cost: Int) {
        self.id = id
        self.dbfId = dbfId
        self.name = name
        self.cardClass = cardClass
        self.cardType = cardType
        self.cost = cost
    }
}

public class Minion: Card {
    var attack, health: Int

    /*
    public required init() {
        log.error("Shouldn't use Minion.init(), implement subclass, or use other initializer")
        fatalError("Should not be an instance of Minion created with this")
    }
    */

    // Call this init from subclasses
    public required init(_ id: String, _ name: String, _ cardClass: Class, _ cost: Int, _ attack: Int, _ health: Int) {
        self.attack = attack
        self.health = health
        super.init(id, 0, name, cardClass, .minion, cost)
    }
}

public class BloodfenRaptor: Minion {
    public required init(_ id: String, _ name: String, _ cardClass: Class, _ cost: Int, _ attack: Int, _ health: Int) {
        super.init(id, "Bloodfen Raptor", cardClass, cost, attack, health)
    }
}

/*
public class BluegillWarrior: Minion {
    public required init() {
        super.init(id: "idk", name: "Bluegill Warrior", cardClass: .neutral)
    }
}

public class SenjinShieldmasta: Minion {
    public required init() {
        super.init(id: "idk", name: "Sen'jin Shieldmasta", cardClass: .neutral)
    }
}

public class Spell: Card {
    public required init() {
        log.error("Shouldn't use Minion.init(), implement subclass, or use other initializer")
        fatalError("Should not be an instance of Minion created with this")
    }
}

public class Weapon: Card {
    public required init() {
        log.error("Shouldn't use Minion.init(), implement subclass, or use other initializer")
        fatalError("Should not be an instance of Minion created with this")
    }
}
*/
