// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Kitura
import LoggerAPI

fileprivate struct UsernameMiddleware: TypeSafeMiddleware {
    var id: String

    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (UsernameMiddleware?, RequestError?) -> ()) {
        if let rv = request.parameters["username"] {
            completion(UsernameMiddleware(id: rv), nil)
        } else {
            completion(nil, ArcanusError.doesNotExist.requestError())
        }
    }
}

fileprivate struct UserPost: Codable {
    let username: String
    let password: String
}

func initializeUserRoutes(app: Server) {
    app.router.get("/profile") { (auth: BasicAuth, respondWith: @escaping (User?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith, code: { res in
            Log.info("authenticated \(auth.id) using \(auth.provider)")
            let user = try Database.shared.userInfo(name: auth.id)
            res(user, nil)
        })
    }

    app.router.get("/users/:username") { (username: UsernameMiddleware, respondWith: @escaping (User?, RequestError?) -> ()) in
        Log.info("Getting profile for \(username.id)")
        handleErrors(respondWith: respondWith, code: { _ in
            respondWith(try Database.shared.userInfo(name: username.id), nil)
        })
    }

    app.router.post("/users") { (user: UserPost, respondWith: @escaping (User?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith, code: { res in
            Log.verbose("Creating user \(user.username)")

            if try Database.shared.userExists(name: user.username) {
                res(nil, ArcanusError.usernameInUse.requestError())
                return
            }

            try Database.shared.addUser(name: user.username, password: user.password)
            res(try Database.shared.userInfo(name: user.username), nil)
        })
    }
}
