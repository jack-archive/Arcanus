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
    
    app.router.post("/user") { request, response, next in
        do {
            guard let str = try request.readString(), let data = str.data(using: .utf8) else {
                ArcanusError.failedToConvertData.setError(response)
                return
            }
            let json = JSON(data: data)
            
            guard let username = json["username"].string, let password = json["password"].string else {
                return
            }
            
            Log.verbose("Creating user \(username)")
            
            if try Database.shared.userExists(name: username) {
                ArcanusError.usernameInUse.setError(response)
                return
            }
            do {
                try Database.shared.addUser(name: username, password: password)
                response.statusCode = .OK
            }
        } catch let error {
            Log.error(error.localizedDescription)
        }
        
        next()
    }
}

func initializeGameRoutes(app: Server) {
    app.router.post("/games") { request, response, next in
        
    }
    
    
    
}
