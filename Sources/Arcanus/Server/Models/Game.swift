// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cryptor
import Foundation
import LoggerAPI
import SwiftKueryORM

final class Game: StringIDModel, CustomStringConvertible {
    var id: String
    
    var player1: String { return Player.joinID(self.id, Player.P1ID) }
    var player2: String { return Player.joinID(self.id, Player.P2ID) }

    var description: String {
        return "Game [\(self.id)] (\(player1) vs \(player2))"
    }

    var open: Bool {
        return self.player2 == Game.GameOpenUsername
    }

    var entityID: Int = 0
    func nextEntityID() -> Int {
        self.entityID += 1
        return self.entityID
    }

    // var passwordToJoin: String?

    //    var user1: String = ""
    static let GameOpenUsername: String = "GAME_OPEN"
    //    var user2: String = GameOpenUser2
    
    func join(user: String) throws {
        guard let p1 = try Player.get(player1),
              let p2 = try Player.get(player2) else {
            throw ArcanusError.databaseError(nil)
        }
        
        if p1.user == Game.GameOpenUsername {
            p1.user = user
        } else if p2.user == Game.GameOpenUsername {
            p2.user = user
        } else {
            throw ArcanusError.gameAlreadyFull
        }
    }
    
    init(user1: String) throws {
        self.id = try Game.generateRandomID()

        var error: Error?
        self.save { game, err in
            if game == nil || err != nil {
                error = ArcanusError.kituraError(err!)
                return
            }
        }
        if error != nil { throw error! }
        Log.verbose("Saved Game with id: \(self.id)")
    }

    fileprivate static let RANDID_BYTES = 8
    public static func generateRandomID() throws -> String {
        return String(format: "%04X-%04X", try Random.generateUInt16(), try Random.generateUInt16())
    }

    static func getGames(open: Bool = false) throws -> [Game] {
        struct OpenParam: QueryParams {
            let user2: String
            init() {
                self.user2 = Game.GameOpenUsername
            }
        }

        var rv: [Game] = []
        var error: RequestError?
        let handler = { (results: [Game]?, err: RequestError?) in
            if err != nil {
                error = err
                return
            }
            rv = results!
        }

        if open {
            Game.findAll(matching: OpenParam(), handler)
        } else {
            Game.findAll(handler)
        }

        if error != nil {
            throw ArcanusError.kituraError(error!)
        }

        return rv
    }

    func start() {
    }
}
