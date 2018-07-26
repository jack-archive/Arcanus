// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Health
import KituraContracts
import KituraNet
import LoggerAPI
import SwiftyJSON

func initializeHealthRoutes(app: Server) {
    app.router.get("/health") { (respondWith: (Status?, RequestError?) -> ()) -> () in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
}

func initializeAuthenticationRoutes(app: Server) {
    app.router.get("/user") { (userProfile: BasicAuth, respondWith: (User?, RequestError?) -> Void) in
        do {
            Log.info("authenticated \(userProfile.id) using \(userProfile.provider)")
            let user = try Database.shared.userInfo(name: userProfile.id)
            respondWith(user, nil)
        } catch let error as ArcanusError {
            respondWith(nil, error.requestError())
        } catch {
            Log.error("Unhandled error!!")
        }
    }
    
    struct UserPost: Codable {
        let username: String
        let password: String
    }
    
    app.router.post("/user") { (user: UserPost, respondWith: (User?, RequestError?) -> Void) in
        do {
            Log.verbose("Creating user \(user.username)")
            
            if try Database.shared.userExists(name: user.username) {
                respondWith(nil, ArcanusError.usernameInUse.requestError())
                return
            }
            do {
                try Database.shared.addUser(name: user.username, password: user.password)
                respondWith(try Database.shared.userInfo(name: user.username), nil)
            }
        } catch let error as ArcanusError {
            respondWith(nil, error.requestError())
        } catch let error {
            Log.error(error.localizedDescription)
        }
    }
}

func initializeGameRoutes(app: Server) {
    app.router.post("/games") { (userProfile: BasicAuth, respondWith: (Game?, RequestError?) -> Void) in
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
