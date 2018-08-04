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
import LoggerAPI
import SwiftKueryORM
import SwiftKuerySQLite

public func serverMain(dbPath: String? = nil) {
    do {
        let server = try Server(dbPath: dbPath)
        try server.run()
    } catch {
    }
}

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class Server {
    let router = Router()
    let cloudEnv = CloudEnv()

    func initModelTable<T: Model>(_ cls: T.Type) {
        do {
            try cls.createTableSync()
        } catch let error {
            Log.warning("\(cls) Table Error: \(error)")
        }
        do {
            let string = "\(try cls.getTable().description(connection: SwiftKueryORM.Database.default!.getConnection()!))"
            Log.info(string)
        } catch let error {
            Log.error("\(cls) Table Error: \(error)")
        }
    }

    public init(dbPath: String? = nil) throws {
        initializeMetrics(router: self.router)

        Log.info("Database path passed was \(dbPath ?? "nil")")
        Database.default = Database(generator: { () -> SQLiteConnection? in
            SQLiteConnection(filename: dbPath ?? "arcanus.db")
        })

        self.initModelTable(User.self)
        self.initModelTable(Game.self)
        self.initModelTable(Player.self)
        self.initModelTable(Test.self)

        Test(id: 1, relate: 1234)
        Test(id: 2, relate: 51)
        
        //Test(id: "hi", relate: "1234")
        //Test(id: "hello", relate: "51")
        
        // Create dev/dev user
        do {
            if try User.get("dev") == nil {
                _ = try User(username: "dev", password: "dev")
                Log.info("Created dev user")
            } else {
                Log.info("dev/dev already created")
            }
        } catch let error {
            Log.error("Failed to initialize dev/dev: \(error)")
        }

        // Print all Users currently registered at startup
        User.findAll { (results: [User]?, error) in
            if results != nil {
                Log.info("Users: \(results!.map({ $0.withoutSensitiveInfo() }))")
            } else {
                Log.error(error!.localizedDescription)
            }
        }

        // Print all Games currently registered at startup
        Game.findAll { (results: [Game]?, error) in
            if results != nil {
                Log.info("Games: \(results!)")
            } else {
                Log.error(error!.localizedDescription)
            }
        }
    }

    func postInit() throws {
        initializeHealthRoutes(app: self)
        initializeUserRoutes(app: self)
        initializeGameRoutes(app: self)
    }

    public func run() throws {
        try self.postInit()
        Kitura.addHTTPServer(onPort: self.cloudEnv.port, with: self.router)
        Kitura.run()
    }
}
