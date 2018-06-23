// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PerfectHTTP
import PerfectHTTPServer
import Dispatch
import PerfectLib
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import PerfectLocalAuthentication
import PerfectLib
import StORM
import PostgresStORM
import JSONConfig

let apiRoutes = Route(method: .get, uri: "/ping", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json")
    response.appendBody(string: "{ \"text\": \"Hello, World!\" }")
    response.completed()
})

public func ServerMain() {
    log.warning("*** Starting Server ***")
    do {
        try GameServer.shared.start()
    } catch {
        fatalError()
    }
}

public class GameServer {
    
    // Singleton, lazy
    public static var shared = GameServer()
    
    var server: HTTPServer = HTTPServer()
    var queue: DispatchQueue
    var games: [Game] = [Game(), Game()]
    let sessionDriver = SessionPostgresDriver()
    
    init() {
        let _ = PerfectCrypto.isInitialized
        queue = DispatchQueue(label: "Arcanus Game Server")
        
        var routes = Routes()
        routes.add(method: .get, uri: "/games", handler: getGames)
        routes.add(method: .post, uri: "/games", handler: createGame)
        routes.add(method: .get, uri: "/games/{id}/", handler: getGameInfo)
        
        // Configuration of Session
        SessionConfig.name = "perfectSession" // <-- change
        SessionConfig.idle = 86400
        SessionConfig.cookieDomain = "localhost" //<-- change
        SessionConfig.IPAddressLock = false
        SessionConfig.userAgentLock = false
        SessionConfig.CSRF.checkState = true
        SessionConfig.CORS.enabled = true
        SessionConfig.cookieSameSite = .lax
        
        var httpPort = 8181
        var baseURL = ""
        
        PostgresConnector.host        = "localhost"
        PostgresConnector.username    = "perfect"
        PostgresConnector.password    = "perfect"
        PostgresConnector.database    = "perfect_testing"
        PostgresConnector.port        = 5432
        
        
        // Login
        do {
            var confData: [String:[[String:Any]]] = [
                "servers": [
                    [
                        "name":"localhost",
                        "port":8181,
                        "routes":[],
                        "filters":[]
                    ]
                ]
            ]
            
            // Load Filters
            confData["servers"]?[0]["filters"] = filters()
            
            // Load Routes
            confData["servers"]?[0]["routes"] = mainRoutes()
            
            try HTTPServer.launch(configurationData: confData)
        } catch {
            fatalError()
        }
        // server.serverPort = 8181
        // server.addRoutes(routes)
    }
    
    func start() throws {
        //try server.start()
    }
    
    func getGames(req: HTTPRequest, res: HTTPResponse) {
        do {
            res.setHeader(.contentType, value: "application/json")
            let json = try games.map({ $0.state.description }).jsonEncodedString()
            res.appendBody(string: json)
            res.completed()
        } catch {
            fatalError()
        }
    }
    
    func createGame(req: HTTPRequest, res: HTTPResponse) {
        do {
            let game = Game()
            game.state = .waitingForPlayers
            log.info("Created game")
            res.appendBody(string: try ["id": games.count].jsonEncodedString())
            games.append(game)
            res.completed()
        } catch {
            
        }
    }
    
    func getGameInfo(req: HTTPRequest, res: HTTPResponse) {
        guard let str = req.urlVariables["id"], let id = Int(str) else {
            log.warning("Bad ID")
            res.completed(status: .notFound)
            return
        }
        log.info("id: \(id)")
        do {
            res.appendBody(string: try ["state": games[id].state].jsonEncodedString())
            res.completed()
        } catch {
            fatalError()
        }
    }
}

public class Game {
    public enum State: CustomStringConvertible, JSONConvertible {
        case waitingForPlayers
        case running
        case finished
        
        public var description: String {
            switch self {
            case .waitingForPlayers: return "Waiting for Players"
            case .running: return "Running"
            case .finished: return "Finished"
            }
        }
        
        public func jsonEncodedString() throws -> String {
            return self.description
        }
    }
    
    var state: State = .finished
}
