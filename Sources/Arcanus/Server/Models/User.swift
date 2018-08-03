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
import SwiftKueryORM
import SwiftKuerySQLite

struct BasicAuth: TypeSafeHTTPBasic {
    var id: String
    var user: User

    static func verifyPassword(username: String, password: String, callback: @escaping (BasicAuth?) -> ()) {
        do {
            if var user = try User.get(username, keepHash: true), let hash = try? User.hashPassword(password, salt: user.saltBytes), user.hashBytes == hash {
                user.clearSensitiveInfo()
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
    private(set) var salt: String
    private(set) var hash: String

    var saltBytes: [UInt8] { return CryptoUtils.byteArray(fromHex: self.salt) }

    var hashBytes: [UInt8] { return CryptoUtils.byteArray(fromHex: self.hash) }

    init(username: String, password: String) throws {
        self.id = username
        let salt = try User.generateSalt()
        self.salt = CryptoUtils.hexString(from: salt)
        self.hash = CryptoUtils.hexString(from: try User.hashPassword(password, salt: salt))
        defer {
            self.clearSensitiveInfo()
        }

        var error: Error?
        self.save { _, err in
            if err != nil {
                error = err!
            }
        }
        if error != nil { throw error! }
    }

    static func generateSalt() throws -> [UInt8] {
        return try Random.generate(byteCount: self.PBKDFKeyLength)
    }

    private static let PBKDFRounds: uint = 5
    private static let PBKDFKeyLength: Int = 32
    static func hashPassword(_ password: String, salt: [UInt8]) throws -> [UInt8] {
        let key = try PBKDF.deriveKey(fromPassword: password, salt: salt, prf: .sha256, rounds: PBKDFRounds, derivedKeyLength: UInt(PBKDFKeyLength))
        return key
    }

    // Hide password hash and salt
    mutating func clearSensitiveInfo() {
        self.salt = ""
        self.hash = ""
    }

    func withoutSensitiveInfo() -> User {
        var rv = self
        rv.clearSensitiveInfo()
        return rv
    }

    /// Gets the user with the specified name out of the Database
    static func get(_ username: String, keepHash: Bool = false) throws -> User? {
        struct IdParam: QueryParams {
            let id: String
            init(_ id: String) {
                self.id = id
            }
        }

        var rv: User?
        var error: RequestError?
        User.findAll(matching: IdParam(username)) { (results: [User]?, err: RequestError?) in
            if results != nil {
                if results!.count == 1 {
                    rv = results![0]
                } else if results!.count == 0 {
                    rv = nil
                } else {
                    error = ArcanusError.databaseError(nil).requestError()
                }
            } else {
                error = err
            }
        }

        if error == nil {
            if !keepHash && rv != nil {
                rv!.clearSensitiveInfo()
            }
            return rv
        } else {
            throw error!
        }
    }
}
