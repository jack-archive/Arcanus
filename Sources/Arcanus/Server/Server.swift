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

public func ServerMain() {
    log.warning("*** Starting Server ***")
    Server.shared.start()
}

public class Server {
    // Singleton, lazy
    public static var shared = Server()
    
    var server: HTTPServer = HTTPServer()
    var queue: DispatchQueue
    var games: [Game] = []
    
    init() {
        queue = DispatchQueue(label: "Arcanus Game Server")
        server.serverPort = 8181
        server.addRoutes(initRoutes())
    }
    
    func start() {
        do {
            try self.server.start()
        } catch {
            fatalError()
        }
    }
    
    func gameFromRequest(_ req: HTTPRequest) throws -> Game? {
        guard let str = req.urlVariables["id"], let id = Int(str) else {
            log.warning("Bad ID / Request")
            return nil
        }
        if id < 0 || id >= games.count {
            throw ArcanusError.gameNotFound
        }
        return games[id]
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
    
    static func fromRequest(_ req: HTTPRequest) throws -> User {
        let username = req.headers.filter({ $0.0 == HTTPRequestHeader.Name.authorization })[0].1
        
        guard let user = User.forUsername(username) else {
            throw ArcanusError.unregisteredUsername
        }
        log.info("user: \(user.username)")
        
        return user
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
    
    var state: State = .waitingForPlayers
    var index: Int
    var timeCreated: Date
    var users: [User]
    
    init(user1: User, index: Int) {
        self.users = [user1]
        self.index = index
        self.timeCreated = Date()
    }
    
    func join(asUser user: User) throws {
        if user.game != nil {
            throw ArcanusError.alreadyInGame
        }
        if state != .waitingForPlayers || users.count >= 2 {
            throw ArcanusError.gameNotAvaliable
        }
        users.append(user)
        
        if users.count == 2 {
            state = .running
        }
    }
}
