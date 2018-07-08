// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKuery
import SwiftKuerySQLite
import LoggerAPI

public class Database {
    
    class User: Table {
        enum Columns: String {
            case id
            case username
            case password
        }
        
        let tableName = "User"
        let id = Column(Columns.id.rawValue, Int32.self, primaryKey: true, notNull: true, unique: true)
        let username = Column(Columns.username.rawValue, String.self, unique: true)
        let password = Column(Columns.password.rawValue, String.self, notNull: true)
    }
    
    let db: SQLiteConnection
    
    init(path: String = "arcanus.db") throws {
        db = SQLiteConnection(filename: path)
        
        db.connect(onCompletion: { err in
            if err == nil {
                Log.info("Successfully opened database connection to \(path)")
            }
            else if let error = err {
                Log.error("Failed to open database connection to \(path): \(error)")
            }
        })
        
        if !db.isConnected {
            Log.error("Database is not connected.")
            throw ArcanusError.failedToOpenDatabase
        } else {
            Log.info("Database is connected!")
        }
        
        let userSchema = User()
        userSchema.create(connection: db) { (result) in
            if result.success {
                Log.info("Created User table")
            } else if let err = result.asError {
                Log.error("Failed to create User table: \(err)")
            }
            sleep(1)
            Log.error("BEFORE")
        }
        Log.error("AFTER")
        
        let titleQuery = Select(userSchema.id, userSchema.username, userSchema.password, from: userSchema).order(by: .ASC(userSchema.id))
        let str = try titleQuery.build(queryBuilder: db.queryBuilder)
        Log.info("\(str)")
        
        db.execute(query: titleQuery) { (result) in
            if let rows = result.asRows {
                for row in rows {
                    Log.debug("Got \(row)")
                }
            } else {
                Log.warning("Bad Query")
            }
        }
    }
    
}
