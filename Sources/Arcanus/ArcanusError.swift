// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum ArcanusError: Int, Error {
    case unknownError = 99
    case badPath
    case failedToConvertData
    case jsonError

    case unregisteredUsername
    case usernameInUse

    case gameNotFound
    case alreadyInGame
    case gameAlreadyFull
 /*
    func statusCode() -> HTTPResponseStatus {
        switch self {
        case .unknownError: return .internalServerError
        case .jsonError: return .badRequest

        case .unregisteredUsername: return .custom(code: 422, message: "Unprocessable Entity")
        case .usernameInUse: return .custom(code: 422, message: "Unprocessable Entity")

        case .gameNotFound: return .notFound
        case .alreadyInGame: return .custom(code: 422, message: "Unprocessable Entity")
        case .gameAlreadyFull: return .custom(code: 422, message: "Unprocessable Entity")
        }
    }

    func setError(_ res: HTTPResponse,
                  info: [String: Any] = [:],
                  status: HTTPResponseStatus? = nil,
                  complete: Bool = true) {
        let dict: [String: Any] = ["error": self.rawValue, "description": self.getErrorDescription(), "info": info]
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
    */
    func getErrorDescription() -> String {
        switch self {
        case .unknownError: return "Unknown error"
        case .badPath: return "Bad path"
        case .failedToConvertData: return "Failed to convert data"
        case .jsonError: return "JSON Error"

        case .unregisteredUsername: return "Username has not been registered yet"
        case .usernameInUse: return "Username is already in use"

        case .gameNotFound: return "Game not found"
        case .alreadyInGame: return "Already in a game"
        case .gameAlreadyFull: return "Game is already full"
        }
    }
}
