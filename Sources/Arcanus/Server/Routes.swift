// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Health
import Kitura
import KituraContracts
import KituraNet
import LoggerAPI
import SwiftyJSON

func handleErrors<T>(respondWith: @escaping (T?, RequestError?) -> (),
                     code: (_ res: (T?, RequestError?) -> ()) throws -> ()) {
    do {
        try code(respondWith)
    } catch let error as ArcanusError {
        respondWith(nil, error.requestError())
    } catch let error {
        fatalError("Unhandled Exception! \(error)")
    }
}

func initializeHealthRoutes(app: Server) {
    app.router.get("/health") { (respondWith: (Status?, RequestError?) -> ()) -> () in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
}
