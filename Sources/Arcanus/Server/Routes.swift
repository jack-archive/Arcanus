//
//  Routes.swift
//  Arcanus
//
//  Created by Jack Maloney on 6/24/18.
//

import Foundation
import PerfectHTTP

func initRoutes() -> Routes {
    var routes = Routes()
    routes.add(method: .get, uri: "/ping", handler: ping)
    routes.add(method: .post, uri: "/register", handler: register)
    routes.add(method: .get, uri: "/games", handler: getGames)
    routes.add(method: .post, uri: "/games", handler: createGame)
    routes.add(method: .get, uri: "/games/{id}", handler: getGameInfo)
    routes.add(method: .post, uri: "/games/{id}", handler: joinGame)
    routes.add(method: .post, uri: "/games/{id}/start", handler: startGame)
    return routes
}

// MARK: Handlers

func ping(req: HTTPRequest, res: HTTPResponse) {
    res.setHeader(.contentType, value: "application/json")
    res.appendBody(string: "{ \"text\": \"Hello, World!\" }")
    res.completed()
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
        let json = try Server.shared.games.map({ $0.state.description }).jsonEncodedString()
        res.appendBody(string: json)
        res.completed()
    } catch {
        ArcanusError.unknownError.setError(res)
    }
}

func createGame(req: HTTPRequest, res: HTTPResponse) {
    do {
        guard let user = errorWrapper(res, { try User.fromRequest(req) })  else {
            return
        }

        let game = Game(user1: user, index: Server.shared.games.count)
        game.state = .waitingForPlayers
        log.info("Created game")
        res.appendBody(string: try ["id": game.index].jsonEncodedString())
        Server.shared.games.append(game)
        res.completed()
    } catch {
        fatalError()
    }
}

func joinGame(req: HTTPRequest, res: HTTPResponse) {
    errorWrapper(res) {
        let user = try User.fromRequest(req)

        let tmp = try Server.shared.gameFromRequest(req)
        guard let game = tmp else {
                return
        }

        try game.join(asUser: user)

        res.addHeader(.contentType, value: "application/json")
        res.appendBody(string: try! ["id": game.index].jsonEncodedString()) //swiftlint:disable:this force_try
        res.completed()
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
        if id < 0 || id >= Server.shared.games.count {
            ArcanusError.gameNotFound.setError(res, info: ["id": id])
        }
        res.appendBody(string: try ["state": Server.shared.games[id].state].jsonEncodedString())
        res.completed()
    } catch {
        fatalError()
    }
}

func startGame(req: HTTPRequest, res: HTTPResponse) {
    errorWrapper(res) {
        let user = try User.fromRequest(req)

        let tmp = try Server.shared.gameFromRequest(req)
        guard let game = tmp else {
            return
        }

    }
}
