// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PerfectHTTP
import PerfectHTTPServer
import Dispatch
import PerfectLib
import SQLiteStORM
import PerfectTurnstileSQLite

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
        print(req.postBodyString!)
    }
}

public class Game {
    public enum State: CustomStringConvertible {
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
    }
    
    var state: State = .waitingForPlayers
}
