// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import Crypto
import FluentSQLite
import Foundation
import Vapor

final class User: SQLiteModel, Migration {
    typealias ID = Int

    var id: ID?
    private(set) var username: String
    private(set) var hash: String

    private static let BCryptWork: Int = 5

    init(username: String, toHash password: String) throws {
        self.username = username

        // Automatically generates salt, and stores it in the hash for later parsing
        self.hash = try BCrypt.hash(password, cost: User.BCryptWork)
    }

    func verify(_ password: String) throws -> Bool {
        return try BCrypt.verify(password, created: self.hash)
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.username
    static let passwordKey: WritableKeyPath<User, String> = \.hash
}

extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}
