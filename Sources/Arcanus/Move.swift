//
//  Move.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/3/18.
//

import Foundation

enum PlayerAction {
    case playCard(PlayCardAction)
}

class PlayCardAction {
    
}

protocol Event {
    var id: Int { get }
}
