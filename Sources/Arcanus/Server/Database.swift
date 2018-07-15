// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Dispatch
import Foundation
import LoggerAPI
import SwiftKuery
import SwiftKuerySQLite

public class Database {
    static var shared: Database!

    class func openSharedDatabase(path: String? = nil) throws {
        if path != nil {
            self.shared = try Database(path: path!)
        } else {
            self.shared = try Database()
        }
    }

    class UserTable: Table {
        enum Columns: String {
            case id
            case username
            case password
        }

        let tableName = "User"
        let id = Column(Columns.id.rawValue, Int32.self, primaryKey: true)
        let username = Column(Columns.username.rawValue, String.self, unique: true)
        let password = Column(Columns.password.rawValue, String.self, notNull: true)
    }

    let db: SQLiteConnection

    init(path: String = "arcanus.db") throws {
        self.db = SQLiteConnection(filename: path)

        self.db.connect(onCompletion: { err in
            if err == nil {
                Log.verbose("Successfully opened database connection to \(path)")
            } else if let error = err {
                Log.error("Failed to open database connection to \(path): \(error)")
            }
        })

        if !self.db.isConnected {
            Log.error("Database is not connected.")
            throw ArcanusError.failedToOpenDatabase
        } else {
            Log.info("Database is connected!")
        }

        let userTable = UserTable()
        let des = try userTable.description(connection: db)
        Log.info(des)
        userTable.create(connection: db) { result in
            if result.success {
                Log.info("Created User table")
            } else if let err = result.asError {
                Log.error("Failed to create User table: \(err)")
            }
        }

        // addUser(name: "jmmaloney4", password: "12345")
        if self.authenticateUser(name: "jmmaloney4", password: "12345") {
            Log.info("Authenticated")
        } else {
            Log.error("Failed to Authenticate")
        }
    }

    @discardableResult func addUser(name: String, password: String) -> Bool {
        if self.userExists(name: name) {
            return false
        }
        var rv = false
        let userTable = UserTable()
        let insert = Insert(into: userTable, columns: [userTable.username, userTable.password], values: [name, password], returnID: true)
        db.execute(query: insert) { res in
            if res.success {
                Log.info("Successfully added User \(name)")
                rv = true
            } else if let err = res.asError {
                Log.error("Failed to create user \(name): \(err)")
                rv = false
            }
        }
        return rv
    }

    func userExists(name: String) -> Bool {
        let userTable = UserTable()
        var rv = false
        // TODO: Filter usernames
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        db.execute(query: query) { res in
            if res.success, let rows = res.asRows {
                rv = true
            }
        }
        return rv
    }

    func authenticateUser(name: String, password: String) -> Bool {
        let userTable = UserTable()
        var rv = false
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        db.execute(query: query) { res in
            if res.success, let rows = res.asRows {
                rv = true
            }
        }
        return rv
    }
}