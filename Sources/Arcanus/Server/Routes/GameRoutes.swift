// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Kitura
import LoggerAPI

func initializeGameRoutes(app: Server) {
    app.router.post("/games") { (userProfile: BasicAuth, respondWith: (Game?, RequestError?) -> ()) in
        do {
            let game = try Game.makeGame(user: try userProfile.user())
            respondWith(game, nil)
        } catch let error as ArcanusError {
            respondWith(nil, error.requestError())
        } catch {
            respondWith(nil, ArcanusError.unknownError.requestError())
        }
    }
}
