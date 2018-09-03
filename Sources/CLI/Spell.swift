//
//  Spell.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 9/2/18.
//

import Foundation

class SpellStats: ICardStats {
    var dbfId: DbfID
    var name: String
    var cost: Int

    convenience init(_ stats: ICardStats) {
        self.init(dbfId: stats.dbfId, name: stats.name, cost: stats.cost)
    }

    init(dbfId: DbfID, name: String, cost: Int) {
        self.dbfId = dbfId
        self.name = name
        self.cost = cost
    }
}

protocol Spell: Card {
    func execute(game: Game) throws -> Bool
}
