// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PerfectHTTP
import PerfectHTTPServer

let apiRoutes = Route(method: .get, uri: "/ping", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json")
    response.appendBody(string: "{ \"text\": \"Hello, World!\" }")
    response.completed()
})

public func ServerMain() {
    log.warning("*** Starting Server ***")
    do {
        try HTTPServer.launch(.server(name: "Arcanus", port: 8181, routes: [apiRoutes]))
    } catch {
        fatalError()
    }
}
