//
//  Game.swift
//  ArcanusPackageDescription
//
//  Created by Jack Maloney on 8/31/18.
//

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

struct BothPlayers<T> {
    private(set) var storage: [T]
    
    subscript(index: Side) -> T {
        get { return storage[index.rawValue] }
        set { self.storage[index.rawValue] = newValue }
    }
    
    init(_ first: T, _ second: T) {
        self.storage = [first, second]
    }
}

enum PlayerAction {
    case playCard(fromHand: Int, toBoard: Int), combat(from: Int, to: Int), heroPower, endTurn
}

class Player {
    var deck: [Card] = []
    var hand: [Card] = []
    var board: [Card] = []
}

class Game {
    // var factory: CardFactory = CardJsonFactory()
    private(set) var decks: BothPlayers<[Card]> = BothPlayers([], [])
    private(set) var hands: BothPlayers<[Card]> = BothPlayers([], [])
    private(set) var board: BothPlayers<[Minion]> = BothPlayers([], [])
    private(set) var controllers: BothPlayers<PlayerController>
    
    init(_ p1: PlayerController, _ p2: PlayerController) {
        self.controllers = BothPlayers(p1, p2)
        self.decks[.first] = self.controllers[.first].getDeck()
        self.decks[.second] = self.controllers[.second].getDeck()
        
        for _ in 0...3 {
            self.hands[.first].append(self.decks[.first].remove(at: 0))
        }
        
        for _ in 0...4 {
            self.hands[.second].append(self.decks[.second].remove(at: 0))
        }
        self.hands[.second].append(TheCoin())
    }
    
    func turn(_ player: Side) {
        // Start of turn triggers
        
        // player draws card
        self.hands[player].append(self.decks[player].remove(at: 0))
        // Run drawn card triggers
        
        // ask player for move
        while true {
            let move: PlayerAction = self.controllers[player].chooseAction()
            print(move)
            
            
            switch move {
            case .playCard(let handI, let boardI):
                guard self.hands[player][handI] is Minion else {
                    continue;
                }
                self.board[player].insert(self.hands[player].remove(at: handI) as! Minion, at: boardI)
            
            case .combat(let myI, let enemyI):
                var mine = self.board[player][myI]
                var theirs = self.board[!player][enemyI]
                
                theirs.health -= mine.attack
                mine.health -= theirs.attack
                
                if mine.isDead {
                    self.board[player].remove(at: myI)
                }
                
                if theirs.isDead {
                    self.board[!player].remove(at: enemyI)
                }
            default: return
            }
        }
    }
    
    func start() {
        while true {
            turn(.first)
            turn(.second)
        }
    }
}

protocol PlayerController {
    var game: Game! { get set }
    var side: Side! { get set }
    
    func getDeck() -> [Card]
    func chooseAction() -> PlayerAction
}

class CLIController: PlayerController {
    var game: Game!
    var side: Side!
    
    func getDeck() -> [Card] {
        return [BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor()]
    }
    
    func chooseAction() -> PlayerAction {
        print("? ")
        if let typed = readLine() {
            if let num = Int(typed) {
                print(num)
                switch num {
                case 0: return .playCard(fromHand: 0, toBoard: 0)
                case 1: return .endTurn
                case 2: return .combat(from: 0, to: 0)
                default: fatalError()
                }
            }
        }
        fatalError()
    }
}
