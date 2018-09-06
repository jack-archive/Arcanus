//
//  Spell.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 9/2/18.
//

import Foundation

class SpellStats: CardStats {
    var dbfId: DbfID
    var name: String
    var text: String
    var cost: Int

    convenience init(_ stats: CardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name, text: stats.text, cost: stats.cost)
    }

    init(dbfId: DbfID, name: String, text: String, cost: Int) {
        self.dbfId = dbfId
        self.text = text
        self.name = name
        self.cost = cost
    }
}

protocol Spell: Card {
    func execute(game: Game) throws -> Bool
}
