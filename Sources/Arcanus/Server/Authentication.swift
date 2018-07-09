// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CredentialsHTTP
import Dispatch
import Foundation
import LoggerAPI
import SwiftKuery
import SwiftKuerySQLite

public struct BasicAuth: TypeSafeHTTPBasic {
    public let id: String
    var password: String?

    static let users = ["jmmaloney4": "12345"]

    init(id: String, password: String? = nil) {
        self.id = id
        self.password = password
    }

    public static func verifyPassword(username: String, password: String, callback: @escaping (BasicAuth?) -> ()) {
        if let storedPassword = users[username], storedPassword == password {
            callback(BasicAuth(id: username))
        } else {
            callback(nil)
        }
    }

    public static func initUserDatabase(path: String = "users.db") throws {
        let cxn = SQLiteConnection(filename: path)

        let group = DispatchGroup()
        group.enter()
        cxn.connect(onCompletion: { err in
            if err == nil {
                Log.info("Successfully opened database connection to \(path)")
            } else if let error = err {
                Log.error("Failed to open database connection to \(path): \(error)")
            }
            group.leave()
        })
        group.wait()

        if !cxn.isConnected {
            Log.error("Database is not connected.")
            throw ArcanusError.failedToOpenDatabase
        } else {
            Log.info("Database is connected!")
        }
    }
}
