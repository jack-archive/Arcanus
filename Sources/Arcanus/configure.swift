// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Authentication
import FluentSQLite
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(_ config: inout Config,
                      _ env: inout Environment,
                      _ services: inout Services) throws {
    // Setup Cards
    addBasicCollection()

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)

    // Configure Fluents SQL provider
    try services.register(FluentSQLiteProvider())

    // Configure the authentication provider
    try services.register(AuthenticationProvider())

    // Configure our database
    var databaseConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)/arcanus.db"))
    databaseConfig.add(database: db, as: .sqlite)
    databaseConfig.enableLogging(on: .sqlite)
    services.register(databaseConfig)

    // Configure our model migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self, database: .sqlite)
    migrationConfig.add(model: AccessToken.self, database: .sqlite)
    migrationConfig.add(model: RefreshToken.self, database: .sqlite)
    migrationConfig.add(model: Game.self, database: .sqlite)
    migrationConfig.add(model: Player.self, database: .sqlite)
    migrationConfig.add(model: Deck.self, database: .sqlite)
    services.register(migrationConfig)
}
