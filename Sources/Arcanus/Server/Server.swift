 // Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CloudEnvironment
import Configuration
import Foundation
import Health
import Kitura
import SwiftKueryORM
import LoggerAPI
import SwiftKuerySQLite

public func serverMain(dbPath: String? = nil) {
    do {
        let server = try Server(path: dbPath)
        try server.run()
    } catch {
    }
}

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class Server {
    let router = Router()
    let cloudEnv = CloudEnv()

    public init(path: String? = nil) throws {
        // Run the metrics initializer
        initializeMetrics(router: self.router)
        // Open database
        // try Database.openSharedDatabase(path: db)
        
        let db = SQLiteConnection(filename: path ?? "arcanus.db")
        
        Log.info("Attempting to open database at \(path)")
        
        db.connect(onCompletion: { err in
            if err == nil {
                Log.verbose("Successfully opened database connection to \(path)")
            } else if let error = err {
                Log.error("Failed to open database connection to \(path): \(error)")
            }
        })
        
        SwiftKueryORM.Database.default = SwiftKueryORM.Database(single: db)
        
        do { try User.createTableSync() } catch {}
        do { try Game.createTableSync() } catch {}
        
        do {
            let user = try User(username: "jmmaloney4", password: "12345")
            user.save { (user, err) in
                if err != nil {
                    Log.error("ERROR!! \(err!)")
                } else {
                    Log.info("\(user!)")
                }
            }
        } catch let err {
            Log.error("\(err)")
        }
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        initializeUserRoutes(app: self)
        // initializeGameRoutes(app: self)
    }

    public func run() throws {
        try self.postInit()
        Kitura.addHTTPServer(onPort: self.cloudEnv.port, with: self.router)
        Kitura.run()
    }
}
