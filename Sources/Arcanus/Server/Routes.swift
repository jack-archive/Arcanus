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
    app.router.get("/user") { (userProfile: BasicAuth, respondWith: (BasicAuth?, RequestError?) -> ()) -> () in
        Log.info("authenticated \(userProfile.id) using \(userProfile.provider)")
        respondWith(userProfile, nil)
    }

    app.router.post("/user") { request, response, next in
        guard let str = try? request.readString(), let data = str?.data(using: .utf8) else {
            ArcanusError.failedToConvertData.setError(response)
            return
        }
        let json = JSON(data: data)

        guard let username = json["username"].string, let password = json["password"].string else {
            return
        }

        Log.verbose("Creating user \(username)")
        
        if Database.shared.userExists(name: username) {
            ArcanusError.usernameInUse.setError(response)
            return
        }
        
        Database.shared.addUser(name: username, password: password)
        response.statusCode = .OK
        
        next()
    }
}

func initializeGameRoutes(app: Server) {
    
}
