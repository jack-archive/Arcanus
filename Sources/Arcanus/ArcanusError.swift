// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import KituraNet
import Kitura
import SwiftyJSON

public enum ArcanusError: Swift.Error {
    case unknownError
    case badPath
    case failedToConvertData
    case failedToOpenDatabase
    case jsonError
    case databaseError(Swift.Error?)

    case unregisteredUsername
    case usernameInUse

    case gameNotFound
    case alreadyInGame
    case gameAlreadyFull
 
    func statusCode() -> HTTPStatusCode {
        switch self {
        case .unknownError: return .internalServerError
        case .badPath: return .internalServerError
        case .failedToConvertData: return .internalServerError
        case .failedToOpenDatabase: return .internalServerError
        case .jsonError: return .badRequest
        case .databaseError: return .internalServerError

        case .unregisteredUsername: return .unprocessableEntity
        case .usernameInUse: return .unprocessableEntity

        case .gameNotFound: return .notFound
        case .alreadyInGame: return .unprocessableEntity
        case .gameAlreadyFull: return .unprocessableEntity
        }
    }
    

    @available(*, deprecated) func setError(_ res: RouterResponse,
                  info: Info = [:],
                  status: HTTPStatusCode? = nil)
    {
        if status != nil {
            res.statusCode = status!
        } else {
            res.statusCode = self.statusCode()
        }
        
        
        if let str = JSON(self.json(info: info)).rawString(encoding: .utf8) {
            res.send(str)
        } else {
            fatalError("Couldn't convert JSON")
        }
    }
  
    typealias Info = [String:String]
    
    struct Json: Codable {
        let error: String
        let desciption: String
        let info: Info
    }
    
    func json(info: Info = [:]) -> Json {
        return Json(error: "\(self)", desciption: self.getErrorDescription(), info: info)
    }
    
    func requestError(info: Info = [:]) -> RequestError {
        return RequestError(RequestError.init(httpCode: self.statusCode().rawValue), body: self.json(info: info))
    }
    
    func getErrorDescription() -> String {
        switch self {
        case .unknownError: return "Unknown error"
        case .badPath: return "Bad path"
        case .failedToConvertData: return "Failed to convert data"
        case .failedToOpenDatabase: return "Failed to open database"
        case .jsonError: return "JSON Error"
        case .databaseError(let err): return "Database error\(err == nil ? ": \(err!)" : "")"

        case .unregisteredUsername: return "Username has not been registered yet"
        case .usernameInUse: return "Username is already in use"

        case .gameNotFound: return "Game not found"
        case .alreadyInGame: return "Already in a game"
        case .gameAlreadyFull: return "Game is already full"
        }
    }
    
    var localizedDescription: String {
        return self.getErrorDescription()
    }
}
