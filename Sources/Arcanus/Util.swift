// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cryptor
import Foundation

/// Code will only run in Debug configuration
public func DEBUG(_ code: () throws -> ()) throws {
    if _isDebugAssertConfiguration() {
        try code()
    }
}

private class GetNamespaceClass {}

/// Will get the Arcanus namespace as a string
func namespaceAsString() -> String {
    return String(reflecting: GetNamespaceClass.self).components(separatedBy: ".")[0]
}

extension Random {
    fileprivate static func generateInt<T: Any>() throws -> T {
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        let byteCount = MemoryLayout<T>.size / MemoryLayout<UInt8>.stride
        pointer.withMemoryRebound(to: UInt8.self, capacity: byteCount) { ptr in
            Random.generate(bytes: ptr, byteCount: byteCount)
        }
        return pointer.pointee
    }

    static func generateInt64() throws -> Int64 { return try self.generateInt() }
    static func generateUInt64() throws -> UInt64 { return try self.generateInt() }
    static func generateInt() throws -> Int { return try self.generateInt() }
    static func generateUInt() throws -> UInt { return try self.generateInt() }
    static func generateInt16() throws -> Int16 { return try self.generateInt() }
    static func generateUInt16() throws -> UInt16 { return try self.generateInt() }
}
