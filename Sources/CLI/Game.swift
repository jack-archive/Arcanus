//
//  Game.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 8/31/18.
//

import Foundation

struct BothPlayers<T> {
    enum Index: Int {
        case first = 0, second = 1
    }
    
    var storage: [T]

    subscript(index: Index) -> T {
        get { return storage[index.rawValue] }
        set { self.storage[index.rawValue] = newValue }
    }
    
    init(_ first: T, _ second: T) {
        self.storage = [first, second]
    }
}

class Game {
    
}
