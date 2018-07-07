// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PerfectHTTP

public enum ArcanusError: Int, Error {
    case unknownError = 99
    case jsonError = 100

    case unregisteredUsername
    case usernameInUse

    case gameNotFound
    case alreadyInGame
    case gameNotAvaliable

    func statusCode() -> HTTPResponseStatus {
        switch self {
        case .jsonError: return .badRequest
        case .unregisteredUsername: return .custom(code: 422, message: "Unprocessable Entity")
        case .usernameInUse: return .custom(code: 422, message: "Unprocessable Entity")
        case .unknownError: return .internalServerError
        case .gameNotFound: return .notFound
        case .alreadyInGame: return .custom(code: 422, message: "Unprocessable Entity")
        case .gameNotAvaliable: return .custom(code: 422, message: "Unprocessable Entity")
        }
    }

    func setError(_ res: HTTPResponse,
                  info: [String: Any] = [:],
                  status: HTTPResponseStatus? = nil,
                  complete: Bool = true) {
        let dict: [String: Any] = ["error": self.rawValue, "info": info]
        if let str = try? dict.jsonEncodedString() {
            res.appendBody(string: str)
            if complete {
                if status == nil {
                    res.completed(status: self.statusCode())
                } else {
                    res.completed(status: status!)
                }
            }
        } else {
            fatalError("Couldn't convert JSON")
        }
    }
}
