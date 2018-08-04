//
//  Player.swift
//  Arcanus
//
//  Created by Jack Maloney on 7/29/18.
//

import Foundation
import SwiftKueryORM

struct Player: Model {
    var game: String
    var pid: Int
    
    var id: String {
        return "\(game):\(pid)"
    }
    
    // Deckstring encoded in DB
    var handStorage: String
    var deckStorage: String
    
    var hand: [Card] {
        return []
    }
    var deck: [Card] {
        return []
    }
}


