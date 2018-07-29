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
    
    func initModelTable<T: Model>(_ cls: T.Type) {
        do {
            try cls.createTableSync()
        }
        catch let error {
            Log.error("\(cls) Table Error: \(error)")
        }
    }
    
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
        
        initModelTable(User.self)
        initModelTable(Game.self)
        
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
        
        User.findAll { (results: [User]?, error) in
            if results != nil {
                Log.info("Users: \(results!.map({ $0.withoutSensitiveInfo() }))")
            } else {
                Log.error(error!.localizedDescription)
            }
        }
        
        Game.findAll { (results: [Int: Game]?, error) in
            if results != nil {
                Log.info("Games: \(results!)")
            } else {
                Log.error(error!.localizedDescription)
            }
        }
        
    }
    
    func postInit() throws {
        // Endpoints
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
