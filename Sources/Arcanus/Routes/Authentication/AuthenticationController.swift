// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

struct AuthenticationController {
    
    func authenticationContainer(for refreshToken: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap { user in
            guard let user = user else {
                throw Abort(.notFound)
            }
            return try self.authenticationContainer(for: user, on: connection)
        }
    }
    
    func authenticationContainer(for user: User, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        return try removeAllTokens(for: user, on: connection).flatMap { _ in
            return try map(to: AuthenticationContainer.self, self.accessToken(for: user, on: connection), self.refreshToken(for: user, on: connection)) { access, refresh in
                return AuthenticationContainer(accessToken: access, refreshToken: refresh)
            }
        }
    }
    
    func revokeTokens(forUsername username: String, on connection: DatabaseConnectable) throws -> Future<Void> {
        return User.query(on: connection).filter(\.username == username).first().flatMap { user in
            guard let user = user else {
                return Future.map(on: connection) { Void() }
            }
            return try self.removeAllTokens(for: user, on: connection)
        }
    }
}

private extension AuthenticationController {
    
    func existingUser(matchingTokenString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<User?> {
        return RefreshToken.query(on: connection).filter(\.tokenString == tokenString).first().flatMap { token in
            guard let token = token else {
                throw Abort(.notFound /* token not found */)
            }
            return User.query(on: connection).filter(\.id == token.userID).first()
        }
    }
    
    func existingUser(matching user: User, on connection: DatabaseConnectable) throws -> Future<User?> {
        return User.query(on: connection).filter(\.username == user.username).first()
    }
    
    func removeAllTokens(for user: User, on connection: DatabaseConnectable) throws -> Future<Void> {
        let accessTokens = AccessToken.query(on: connection).filter(\.userID == user.id!).delete()
        let refreshToken = RefreshToken.query(on: connection).filter(\.userID == user.id!).delete()
        
        return map(to: Void.self, accessTokens, refreshToken) { _, _ in Void() }
    }
    
    func accessToken(for user: User, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: user.requireID()).save(on: connection)
    }
    
    func refreshToken(for user: User, on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userID: user.requireID()).save(on: connection)
    }
    
    func accessToken(for refreshToken: RefreshToken, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: refreshToken.userID).save(on: connection)
    }
}
