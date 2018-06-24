//
//  Error.swift
//  Arcanus
//
//  Created by Jack Maloney on 6/24/18.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer

public enum ArcanusError: Int, Error {
    case unknownError = 99
    case jsonError = 100
    
    case unregisteredUsername
    case usernameInUse
    
    case gameNotFound
    
    func statusCode() -> HTTPResponseStatus {
        switch self {
        case .jsonError: return .badRequest
        case .unregisteredUsername: return .custom(code: 422, message: "Unprocessable Entity")
        case .usernameInUse: return .custom(code: 422, message: "Unprocessable Entity")
        case .unknownError: return .internalServerError
        case .gameNotFound: return .notFound
        }
    }
    
    func setError(_ res: HTTPResponse, info: [String: Any] = [:], status: HTTPResponseStatus? = nil, complete: Bool = true) {
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
