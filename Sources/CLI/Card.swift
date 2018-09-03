//
//  Card.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 9/2/18.
//

import Foundation

protocol Card: AnyObject, ICardStats, CustomStringConvertible {
    static var stats: Stats { get }
    var stats: Stats { get set }

    init()
}

extension Card {
    var description: String {
        return "<\(self.name)>"
    }
}

extension Card {
    var dbfId: DbfID { return self.stats.cardStats.dbfId }
    var name: String { get { return self.stats.cardStats.name } set { self.stats.cardStats.name = newValue } }
    var cost: Int { get { return self.stats.cardStats.cost } set { self.stats.cardStats.cost = newValue } }
}
