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
    
    init() {
        queue = DispatchQueue(label: "Arcanus Game Server")
        
        var routes = Routes()
        routes.add(method: .get, uri: "/games", handler: getGames)
        routes.add(method: .post, uri: "/games", handler: createGame)
        routes.add(method: .get, uri: "/games/{id}", handler: getGameInfo)
        
        server.serverPort = 8181
        server.addRoutes(routes)
    }
    
    func start() throws {
        try server.start()
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
            let username = req.headers.filter({ $0.0 == HTTPRequestHeader.Name.authorization })[0].1
            log.info("user: \(username)")
            
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

public class Player {
    static var index: [String:Player] = [:]
    
    var username: String
    weak var game: Game?
    
    private init(username: String) { self.username = username }
    
    public static func forUsername(_ username: String) -> Player? {
        return index[username]
    }
    
    public static func registerUsername(_ username: String) -> Player? {
        if index[username] != nil {
            return nil
        }
        let player = Player(username: username)
        index[username] = player
        return player
    }
    
    func joinGame(_ game: Game) -> Bool {
        if self.game == nil {
            self.game = game
            return true
        }
        return false
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
