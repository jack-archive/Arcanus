// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKueryORM
import Cryptor
import LoggerAPI

final class Game: Model, CustomStringConvertible {
    enum Access: String {
        case pub = "Public"
        case priv = "Private"
    }
    
    var id: String
    
    var description: String {
        return "Game [\(id)]"
    }
    
    // var passwordToJoin: String?
    
    var user1: String
    static let GameOpenUser2: String = "GAME_OPEN"
    var user2: String = GameOpenUser2
    // var user2: String?
    // var user2: String
    // var user2: String!
    // var state: String!
    // var config: String!

    init(user1: String) throws {
        self.id = try Game.generateRandomID()
        self.user1 = user1
        
        var error: Error?
        self.save { (game, err) in
            if game == nil {
                error = ArcanusError.kituraError(err!)
                return
            }
        }
        if error != nil { throw error! }
        Log.verbose("Saved game with id: \(self.id)")
    }
    
    fileprivate static let RANDID_BYTES = 8
    public static func generateRandomID() throws -> String {
        return String(format: "%04X-%04X", try Random.generateUInt16(), try Random.generateUInt16())
    }
    
    static func getGames(open: Bool = false) throws -> [Game] {
        struct OpenParam: QueryParams {
            let user2: String
            init() {
                user2 = Game.GameOpenUser2
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
}
