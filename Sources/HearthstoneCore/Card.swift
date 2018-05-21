// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public func stuff() {
    print("yo")
    if let bloodfen = NSClassFromString("\(namespaceAsString()).BloodfenRaptor") as? Card.Type {
        let instance = bloodfen.init() as! BloodfenRaptor
        print(instance.name)
    }
}

public class Card {
    public static func makeNameClassReady(_ name: String) -> String {
        return name.replacingOccurrences(of: " ", with: "")
                   .replacingOccurrences(of: "'", with: "")
    }
    public static func classForName(_ name: String) -> Card.Type? {
        let readyName = makeNameClassReady(name)
        return NSClassFromString("\(namespaceAsString()).\(readyName)") as? Card.Type
    }
    
    public enum Class {
        case neutral
        case druid, hunter, mage, paladin, priest, rouge, shaman, warlock, warrior
    }
    
    enum CardType {
        case minion, spell, weapon
    }
    
    enum Mechanics {
        case charge, taunt, windfury
        case battlecry, deathrattle
    }
    
    var id: String
    public var name: String
    var cardClass: Class
    
    required public init() {
        id = ""
        name = ""
        cardClass = .neutral
    }
    
    public init(id: String, name: String, cardClass: Class) {
        self.id = id
        self.name = name
        self.cardClass = cardClass
    }
}

public class Minion: Card {
    
}

public class BloodfenRaptor: Minion {
    public required init() {
        super.init(id: "idk", name: "Bloodfen Raptor", cardClass: .neutral)
    }
}

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
    
}

public class Weapon: Card {
    
}
