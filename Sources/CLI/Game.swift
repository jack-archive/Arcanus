// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum Side: Int {
    case first = 0
    case second = 1

    static prefix func ! (side: Side) -> Side {
        switch side {
        case .first: return .second
        case .second: return .first
        }
    }
}

extension Array where Element == Player {
    subscript(index: Side) -> Player {
        get { return self[index.rawValue] }
        set { self[index.rawValue] = newValue }
    }
}

enum PlayerAction {
    case playCard(fromHand: Int, toBoard: Int)
    case combat(from: Int, to: Int)
    case heroPower
    case endTurn
}

class Game {
    var players: [Player] = []
    var currentSide: Side = .first
    var currentPlayer: Player {
        get {
            return self.players[currentSide]
        }
        set {
            self.players[currentSide] = newValue
        }
    }

    init(_ p1: PlayerController, _ p2: PlayerController) {
        self.players = [Player(p1), Player(p2)]

        // TODO: Randomize
        p1.game = self
        p1.side = .first
        p2.game = self
        p2.side = .second

        for _ in 0...3 {
            self.players[.first].drawCard()
        }

        for _ in 0...4 {
            self.players[.second].drawCard()
        }
        self.players[.second].hand.append(TheCoin())
    }

    func turn(_ player: Side) {
        self.players[player].drawCard()

        while true {
            let move: PlayerAction = self.players[player].controller.chooseAction()
            print(move)

            switch move {
            case let .playCard(handI, boardI):
                let card = self.players[player].hand.remove(at: handI)
                if let minion = card as? Minion {
                    self.players[player].board.insert(minion, at: boardI)
                } else if let spell = card as? Spell {
                    do { try spell.execute(game: self) }
                    catch {}
                }
            case let .combat(myI, enemyI):
                var mine = self.players[player].board[myI]
                var theirs = self.players[!player].board[enemyI]

                theirs.health -= mine.attack
                mine.health -= theirs.attack

                if mine.isDead {
                    self.players[player].board.remove(at: myI)
                }

                if theirs.isDead {
                    self.players[!player].board.remove(at: enemyI)
                }
            default: return
            }
        }
    }

    func start() {
        while true {
            self.currentSide = .first
            self.turn(.first)
            self.currentSide = .second
            self.turn(.second)
        }
    }
}

protocol PlayerController: AnyObject {
    var game: Game! { get set }
    var side: Side! { get set }
    var player: Player! { get set }

    func getDeck() -> [Card]
    func chooseAction() -> PlayerAction
}

extension PlayerController {
    var player: Player! {
        get {
            guard self.game != nil else { return nil }
            return game.players[self.side]
        }
        set {
            self.game.players[self.side] = newValue
        }
    }
}
