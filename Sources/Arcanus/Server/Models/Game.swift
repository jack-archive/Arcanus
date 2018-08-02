// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKueryORM

final class Game: Model {
    var id: Int
    var user1: String // = nil
    // var user2: String
    // var user2: String! // = nil
    // var state: String! = nil
    // var config: String! = nil

    init(user1: String) throws {
        self.id = 1
        self.user1 = user1
        // self.user2 = ""
        
        var error: Error?
        self.save { (game, err) in
            if game == nil {
                error = ArcanusError.kituraError(err!)
                return
            }
            
            // self.id = id!
            
            if err != nil {
                error = err
            }
        }
        if error != nil { throw error! }
    }
    
    /*
    static func makeGame(user: User) throws -> Game {
        let rv = Game()
        rv.user1 = user
        try Database.shared.initGame(game: rv)
        return rv
    }
    */
}
