// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CredentialsHTTP
import Foundation
import LoggerAPI
import SwiftKuery
import SwiftKueryORM
import SwiftKuerySQLite

public final class User: Model {
//     let id: Int32
    let id: String

    init(_ name: String) {
        self.id = name
        
    }
    
    /*
    static func forUsername(_ name: String) throws -> User {
        User.findAll { (result: [User]?, error: RequestError?) in
            
        }
    }
     */
}

public struct BasicAuth: TypeSafeHTTPBasic {
    /// AKA username
    public let id: String

    init(id: String) {
        self.id = id
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

    public func user() throws -> User {
        return try Database.shared.userInfo(name: self.id)
    }
}
