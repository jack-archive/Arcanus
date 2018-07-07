// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Dispatch
import Foundation
import JSONConfig
import PerfectCrypto
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib

public func serverMain() {
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
        self.queue = DispatchQueue(label: "Arcanus Game Server")
        self.server.serverPort = 8181
        self.server.addRoutes(initRoutes())
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
        if id < 0 || id >= self.games.count {
            throw ArcanusError.gameNotFound
        }
        return self.games[id]
    }
}

// User ID / Auth, Player stores game related data
public class User {
    static var index: [String: User] = [:]

    var username: String
    weak var game: Game?

    private init(username: String) { self.username = username }

    public static func forUsername(_ username: String) -> User? {
        return self.index[username]
    }

    public static func registerUsername(_ username: String) -> User? {
        if self.index[username] != nil {
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
        case full
        case running
        case finished

        public var description: String {
            switch self {
            case .waitingForPlayers: return "Waiting for Players"
            case .running: return "Running"
            case .finished: return "Finished"
            case .full: return "Full"
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
        if self.state != .waitingForPlayers || self.users.count >= 2 {
            throw ArcanusError.gameNotAvaliable
        }
        self.users.append(user)

        if self.users.count == 2 {
            self.state = .full
        }
    }

    func start() {
        self.state = .running
    }
}
