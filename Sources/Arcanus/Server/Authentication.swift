// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CredentialsHTTP
import Foundation
import LoggerAPI
import SwiftKuery
import SwiftKuerySQLite

public struct User: Codable {
    let id: Int32
    let username: String
}

public struct BasicAuth: TypeSafeHTTPBasic {
    /// AKA username
    public let id: String
    var password: String?
    
    init(id: String, password: String? = nil) {
        self.id = id
        self.password = password
    }
    
    public static func verifyPassword(username: String, password: String, callback: @escaping (BasicAuth?) -> ()) {
        do {
            if try Database.shared.authenticateUser(name: username, password: password) {
                callback(BasicAuth(id: username))
            } else {
                callback(nil)
            }
        } catch let error {
            Log.error(error.localizedDescription)
        }
    }
}
