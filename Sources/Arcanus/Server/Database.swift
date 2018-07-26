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

        let tableName = "Users"
        let id = Column(Columns.id.rawValue, Int32.self, primaryKey: true)
        let username = Column(Columns.username.rawValue, String.self, unique: true)
        let password = Column(Columns.password.rawValue, String.self, notNull: true)
    }

    class GameIndex: Table {
        enum Columns: String {
            case id
            case user1
            case user2
            case state
            case config
        }

        let tableName = "GameIndex"
        let id = Column(Columns.id.rawValue, Int32.self, primaryKey: true)
        let user1 = Column(Columns.user1.rawValue, String.self)
        let user2 = Column(Columns.user2.rawValue, String.self)
        let state = Column(Columns.state.rawValue, String.self)
        let config = Column(Columns.config.rawValue, String.self)
    }

    class GameTable: Table {
    }

    let db: SQLiteConnection

    private func checkTableCreated(_ table: Table) {
        table.create(connection: self.db) { result in
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
        let gameIndex = GameIndex()
        checkTableCreated(userTable)
        checkTableCreated(gameIndex)
    }

    // Execute query and handle errors
    func executeQuery(_ query: Query, handler: @escaping (QueryResult) throws -> ()) throws {
        var error: Error?
        db.execute(query: query) { res in
            if res.success {
                do {
                    try handler(res)
                } catch let err {
                    error = err
                }
            } else if let err = res.asError {
                error = err
                return
            } else {
                error = ArcanusError.unknownError
            }
        }
        if error != nil {
            throw error!
        }
    }

    // MARK: User

    func addUser(name: String, password: String) throws {
        if try self.userExists(name: name) {
            throw ArcanusError.usernameInUse
        }

        let userTable = UserTable()
        let insert = Insert(into: userTable, columns: [userTable.username, userTable.password], values: [name, password], returnID: true)

        try executeQuery(insert) { _ in
            //let user = try self.userInfo(name: name)
            Log.info("Created User '\(name)'")
        }
    }

    func userInfo(name: String) throws -> User {
        let userTable = UserTable()
        var rv: User!
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        try executeQuery(query) { res in
            guard let rows = res.asRows, rows.count == 1, rows[0][UserTable.Columns.username.rawValue] as? String == name,
                let username = rows[0][UserTable.Columns.username.rawValue] as? String else {
                throw ArcanusError.databaseError(nil)
            }
            rv = User(username)
        }
        return rv
    }

    func userExists(name: String) throws -> Bool {
        let userTable = UserTable()
        var rv = false
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)
        try executeQuery(query) { res in
            if let rows = res.asRows,
                rows.count == 1,
                rows[0][UserTable.Columns.username.rawValue] as? String == name {
                rv = true
            }
        }
        return rv
    }

    func authenticateUser(name: String, password: String) throws -> Bool {
        let userTable = UserTable()
        var rv = false
        let query = Select(userTable.id, userTable.username, userTable.password, from: userTable).where(userTable.username == name)

        try executeQuery(query) { res in
            if let rows = res.asRows,
                rows.count == 1,
                rows[0][UserTable.Columns.password.rawValue] as? String == password {
                rv = true
            }
        }
        return rv
    }

    // MARK: Game

    func initGame(game: Game) throws {
        if game.user1 == nil {
            throw ArcanusError.databaseError(nil)
        }

        let gameIndex = GameIndex()
        let insert = Insert(into: gameIndex, columns: [gameIndex.user1], values: [game.user1], returnID: true)
        try executeQuery(insert) { _ in }
    }
}
