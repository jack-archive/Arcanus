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

    class GamesIndex: Table {
        enum Columns: String {
            case id
            case user1
            case user2
            case state
            case config
        }
    }
    
    class GameTable: Table {
        
    }
    
    let db: SQLiteConnection

    private func checkTableCreated(_ table: Table) {
        table.create(connection: db) { result in
            if result.success {
                Log.info("Created \(table.nameInQuery)")
            } else if let err = result.asError {
                Log.error("Failed to create \(table.nameInQuery): \(err)")
            }
        }
    }
    
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
        let gamesIndex = GamesIndex()
        checkTableCreated(userTable)
        checkTableCreated(gamesIndex)
    }

    @discardableResult func addUser(name: String, password: String) throws -> Bool {
        if self.userExists(name: name) {
            return false
        }
        var rv = false
        var err: Error!
        let userTable = UserTable()
        let insert = Insert(into: userTable, columns: [userTable.username, userTable.password], values: [name, password], returnID: true)
        db.execute(query: insert) { res in
            if res.success {
                Log.info("Successfully added User \(name)")
                rv = true
            } else if res.asError != nil {
                err = res.asError!
                Log.error("Failed to create user \(name): \(err)")
                rv = false
            }
        }
        if err != nil {
            throw err
        }
        return rv
    }

    func userExists(name: String) -> Bool {
        let userTable = UserTable()
        var rv = false
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        db.execute(query: query) { res in
            if res.success, let rows = res.asRows {
                if rows.count == 1 && rows[0][UserTable.Columns.username.rawValue] as? String == name {
                    rv = true
                }
            }
        }
        return rv
    }

    func authenticateUser(name: String, password: String) -> Bool {
        let userTable = UserTable()
        var rv = false
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        db.execute(query: query) { res in
            if res.success, let rows = res.asRows,
                rows.count == 1, rows[0][UserTable.Columns.password.rawValue] as? String == password {
                rv = true
            }
        }
        return rv
    }
}
