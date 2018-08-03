// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Kitura
import LoggerAPI

fileprivate struct GetGamesMiddleware: TypeSafeMiddleware, Codable {
    let open: Bool

    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (GetGamesMiddleware?, RequestError?) -> ()) {
        completion(GetGamesMiddleware(open: request.queryParameters["open"]?.boolean ?? false), nil)
    }
}

fileprivate struct GameIDMiddleware: TypeSafeMiddleware {
    var id: String

    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (GameIDMiddleware?, RequestError?) -> ()) {
        if let rv = request.parameters["game"]?.string {
            completion(GameIDMiddleware(id: rv), nil)
        } else {
            completion(nil, ArcanusError.badPath.requestError())
        }
    }
}

fileprivate struct PlayerIDMiddleware: TypeSafeMiddleware {
    var id: Int

    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (PlayerIDMiddleware?, RequestError?) -> ()) {
        if let rv = request.parameters["player"]?.int {
            completion(PlayerIDMiddleware(id: rv), nil)
        } else {
            completion(nil, ArcanusError.badPath.requestError())
        }
    }
}

func initializeGameRoutes(app: Server) {
    struct EmptyPost: Codable {}
    app.router.post("/games") { (auth: BasicAuth, _: EmptyPost, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { _ in
            Log.verbose("\(auth.id) initializing game")
            let game = try Game(user1: auth.user.id)
            respondWith(game, nil)
        }
    }

    struct JoinGamePost: Codable {
    }
    app.router.post("/games/:game/players") { (_: BasicAuth, id: GameIDMiddleware, _: JoinGamePost, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { _ in
            Game.find(id: id.id, { game, error in
                if error != nil || game == nil {
                    respondWith(nil, ArcanusError.databaseError(error).requestError())
                    return
                }

                // game!.user2 = auth.id
                game!.update(id: id.id, { _, error in
                    if error != nil {
                        respondWith(nil, ArcanusError.databaseError(error).requestError())
                    }
                })
            })
        }
    }

    app.router.get("/games") { (_: BasicAuth, params: GetGamesMiddleware, respondWith: @escaping ([Game]?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { _ in
            respondWith(try Game.getGames(open: params.open), nil)
        }
    }

    app.router.get("/games/:game") { (_: BasicAuth, id: GameIDMiddleware, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { _ in
            respondWith(try Game.get(id: id.id), nil)
        }
    }

    /* /games/:gameid/players
     * /games/:gameid/players/:id/
     *
     */

    /*
    app.router.post("/games/:id/players") { (auth: BasicAuth, id: GameIDMiddleware, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            print("\(auth.id)")

        }
    }
 */
}
