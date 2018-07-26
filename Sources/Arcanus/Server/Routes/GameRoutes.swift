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
    var id: Int
    
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (GameIDMiddleware?, RequestError?) -> ()) {
        if let rv = request.parameters["game"]?.int {
            completion(GameIDMiddleware(id: rv), nil)
        } else {
            completion(nil, ArcanusError.badPath.requestError())
        }
    }
}

func initializeGameRoutes(app: Server) {
    app.router.post("/games") { (auth: BasicAuth, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            print("\(auth.id)")
            let game = try Game.makeGame(user: try auth.user())
            respondWith(game, nil)
        }
    }
    
    app.router.get("/games") { (auth: BasicAuth, params: GetGamesMiddleware, respondWith: @escaping (BasicAuth?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            if params.open {
                Log.info("Getting open games")
            } else {
                Log.info("Getting all games")
            }
        }
    }
    
    app.router.get("/games/:game") { (auth: BasicAuth, id: GameIDMiddleware, respondWith: @escaping (BasicAuth?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            
        }
    }
    
    app.router.get("/games/:game/players") { (auth: BasicAuth, game: GameIDMiddleware, respondWith: @escaping (Game?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            print("\(auth.id)")
            print("GAME: \(game.id)")
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
