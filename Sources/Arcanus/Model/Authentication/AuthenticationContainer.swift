// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor

struct AuthenticationContainer: Content {
    let username: String
    let accessToken: AccessToken.Token
    let expiresIn: TimeInterval
    let refreshToken: RefreshToken.Token

    init(_ username: String, accessToken: AccessToken, refreshToken: RefreshToken) {
        self.username = username
        self.accessToken = accessToken.tokenString
        self.expiresIn = AccessToken.accessTokenExpirationInterval
        self.refreshToken = refreshToken.tokenString
    }
}

struct RefreshTokenContainer: Content {
    let refreshToken: RefreshToken.Token
}

struct UsernameContainer: Content {
    let username: String

    init(_ username: String) {
        self.username = username
    }
}
