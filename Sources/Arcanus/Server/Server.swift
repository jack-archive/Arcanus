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
import Foundation

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
    var games: [Game] = []
    
    init() {
        queue = DispatchQueue(label: "Arcanus Game Server")
        
        var routes = Routes()
        routes.add(method: .get, uri: "/games", handler: getGames)
        routes.add(method: .post, uri: "/games", handler: createGame)
        routes.add(method: .get, uri: "/games/{id}", handler: getGameInfo)
        routes.add(method: .post, uri: "/register", handler: register)
        
        server.serverPort = 8181
        server.addRoutes(routes)
    }
    
    func start() throws {
        try server.start()
    }
    
    func register(req: HTTPRequest, res: HTTPResponse) {
        if req.postBodyString == nil {
            ArcanusError.jsonError.setError(res)
        }
        if User.forUsername(req.postBodyString!) != nil {
            ArcanusError.usernameInUse.setError(res)
        }
        if User.registerUsername(req.postBodyString!) != nil {
            log.info("Registered: \(req.postBodyString!)")
            res.completed()
        } else {
            ArcanusError.unknownError.setError(res)
        }
    }
    
    func getGames(req: HTTPRequest, res: HTTPResponse) {
        do {
            res.setHeader(.contentType, value: "application/json")
            let json = try games.map({ $0.state.description }).jsonEncodedString()
            res.appendBody(string: json)
            res.completed()
        } catch {
            ArcanusError.unknownError.setError(res)
        }
    }
    
    func createGame(req: HTTPRequest, res: HTTPResponse) {
        do {
            let username = req.headers.filter({ $0.0 == HTTPRequestHeader.Name.authorization })[0].1
            
            guard let user = User.forUsername(username) else {
                ArcanusError.unregisteredUsername.setError(res)
                return
            }
            log.info("user: \(user.username)")
            
            let game = Game(user1: user, index: games.count)
            game.state = .waitingForPlayers
            log.info("Created game")
            res.appendBody(string: try ["id": game.index].jsonEncodedString())
            games.append(game)
            res.completed()
        } catch {
            
        }
    }
    
    func getGameInfo(req: HTTPRequest, res: HTTPResponse) {
        guard let str = req.urlVariables["id"], let id = Int(str) else {
            log.warning("Bad ID / Request")
            ArcanusError.jsonError.setError(res)
            return
        }
        log.info("id: \(id)")
        do {
            if id < 0 || id >= games.count {
                ArcanusError.gameNotFound.setError(res, info: ["id": id])
            }
            res.appendBody(string: try ["state": games[id].state].jsonEncodedString())
            res.completed()
        } catch {
            fatalError()
        }
    }
}

// User ID / Auth, Player stores game related data
public class User {
    static var index: [String:User] = [:]
    
    var username: String
    weak var game: Game?
    
    private init(username: String) { self.username = username }
    
    public static func forUsername(_ username: String) -> User? {
        return index[username]
    }
    
    public static func registerUsername(_ username: String) -> User? {
        if index[username] != nil {
            return nil
        }
        let player = User(username: username)
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
    
    init(user1: User, index: Int) {
        self.users = [user1]
        self.index = index
        self.timeCreated = Date()
    }
    
    var state: State = .waitingForPlayers
    var index: Int
    var timeCreated: Date
    var users: [User]
    
}
