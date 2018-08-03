// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKueryORM
import Cryptor
import LoggerAPI

public struct Game: Model {
    var id: String
    var user1: String // = nil
    // var user2: String
    // var user2: String! // = nil
    // var state: String! = nil
    // var config: String! = nil

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
        return String(format: "%02X-%02X", try Random.generateUInt16(), try Random.generateUInt16())
    }
}
