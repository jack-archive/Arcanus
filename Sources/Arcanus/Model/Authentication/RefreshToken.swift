// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import FluentSQLite
import Crypto

struct RefreshToken: Content, SQLiteUUIDModel, Migration {
    typealias Token = String
    
    var id: UUID?
    let tokenString: Token
    let userID: User.ID
    
    init(userID: User.ID) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
    }
}
