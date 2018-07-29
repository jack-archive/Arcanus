// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CredentialsHTTP
import Cryptor
import Foundation
import LoggerAPI
import SwiftKuery
import SwiftKuerySQLite
import SwiftKueryORM

struct BasicAuth: TypeSafeHTTPBasic {
    var id: String
    var user: User
    
    static func verifyPassword(username: String, password: String, callback: @escaping (BasicAuth?) -> Void) {
        do {
            if let user = try User.get(username), let hash = try? User.hashPassword(password, salt: user.salt), user.hash == hash {
                callback(BasicAuth(id: user.id, user: user))
            } else {
                callback(nil)
            }
        } catch let error {
            Log.error(error.localizedDescription)
        }
    }
}


struct User: Model, QueryParams {
    let id: String
    let salt: [UInt8]
    let hash: [UInt8]
    
    init(username: String, password: String) throws {
        self.id = username
        self.salt = try User.generateSalt()
        self.hash = try User.hashPassword(password, salt: salt)
    }
    
    static func generateSalt() throws -> [UInt8] {
        return try Random.generate(byteCount: 32)
    }
    
    fileprivate static let PBKDFRounds: uint = 5
    static func hashPassword(_ password: String, salt: [UInt8]) throws -> [UInt8] {
        let key = try PBKDF.deriveKey(fromPassword: password, salt: salt, prf: .sha256, rounds: PBKDFRounds, derivedKeyLength: 32)
        return key
    }
    
    /// Gets the user with the specified name out of the Database
    static func get(_ username: String) throws -> User? {
        struct IdParam: QueryParams {
            let id: String
            
            init(_ id: String) {
                self.id = id
            }
        }
        
        var rv: User?
        var err: RequestError?
        User.findAll(matching: IdParam(username)) { (results: [User]?, error: RequestError?) in
            if results != nil {
                if results!.count == 1 {
                    rv = results![0]
                } else if results!.count == 0 {
                    rv = nil
                } else {
                    err = ArcanusError.databaseError(nil).requestError()
                }
            } else {
                err = error
            }
        }
        
        if err == nil {
            return rv
        } else {
            throw err!
        }
    }
}
