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

func initializeUserRoutes(app: Server) {
    app.router.get("/user") { (auth: BasicAuth, respondWith: @escaping (User?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { _ in
            respondWith(auth.user, nil)
        }
    }

    app.router.get("/users/:username") { (username: UsernameMiddleware, respondWith: @escaping (User?, RequestError?) -> ()) in
        Log.info("Getting profile for \(username.id)")
        handleErrors(respondWith: respondWith) { _ in
            if let user = try User.get(username.id) {
                respondWith(user, nil)
            } else {
                throw ArcanusError.doesNotExist
            }
        }
    }

    struct UserPost: Codable {
        let username: String
        let password: String
    }

    app.router.post("/users") { (post: UserPost, respondWith: @escaping (User?, RequestError?) -> ()) in
        handleErrors(respondWith: respondWith) { res in
            Log.verbose("Creating user \(post.username)")

            if try User.get(post.username) != nil {
                res(nil, ArcanusError.usernameInUse.requestError())
                return
            }

            let user = try User(username: post.username, password: post.password)
            res(user, nil)
        }
    }
}
