// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import FluentSQLite
import Crypto
import Authentication

struct AccessToken: Content, SQLiteUUIDModel, Migration {
    typealias Token = String
    
    static let accessTokenExpirationInterval: TimeInterval = 3600
    
    var id: UUID?
    private(set) var tokenString: Token
    private(set) var userID: User.ID
    let expiryTime: Date
    
    init(userID: User.ID) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
        self.expiryTime = Date().addingTimeInterval(AccessToken.accessTokenExpirationInterval)
    }
}

extension AccessToken: BearerAuthenticatable {
    static let tokenKey: WritableKeyPath<AccessToken, String> = \.tokenString
    
    public static func authenticate(using bearer: BearerAuthorization, on connection: DatabaseConnectable) -> Future<AccessToken?> {
        return Future.flatMap(on: connection) {
            return AccessToken.query(on: connection).filter(tokenKey == bearer.token).first().map { token in
                guard let token = token, token.expiryTime > Date() else { return nil }
                return token
            }
        }
    }
}

extension AccessToken: Token {
    typealias UserType = User
    static var userIDKey: WritableKeyPath<AccessToken, User.ID> = \.userID
}
