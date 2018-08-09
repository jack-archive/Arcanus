// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let authRouteController = AuthenticationRouteController()
    try authRouteController.boot(router: router)

    let userRouteController = UserRouteController()
    try userRouteController.boot(router: router)

    let protectedRouteController = ProtectedRoutesController()
    try protectedRouteController.boot(router: router)

    let cardRouteController = CardRouteController()
    try cardRouteController.boot(router: router)
}
