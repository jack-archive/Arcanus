// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Core

/// Code will only run in Debug configuration
public func DEBUG(_ code: () throws -> Void) throws {
    if _isDebugAssertConfiguration() {
        try code()
    }
}

private class GetNamespaceClass {}

/// Will get the Arcanus namespace as a string
func namespaceAsString() -> String {
    return String(reflecting: GetNamespaceClass.self).components(separatedBy: ".")[0]
}

extension OptionalType {
    func unwrap(or error: @autoclosure @escaping () -> Error) throws -> WrappedType {
        guard let rv = self.wrapped else {
            throw error()
        }
        return rv
    }
}

func toPairs<Element: Any>(_ self: Array<Element>) -> [(Element, Element)]? {
    if self.count % 2 != 0 {
        return nil
    }
    
    var working = self
    var rv: [(Element, Element)] = []
    
    while !working.isEmpty {
        let pair = working.dropLast(working.count - 2)
        rv.append((pair[0], pair[1]))
        working.removeFirst(2)
    }
    
    return rv
}

extension ArraySlice {
    func toPairs() -> [(Element, Element)]? {
        let copy = Array(self)
        return Arcanus.toPairs(copy)
    }
}

extension Array {
    func toPairs() -> [(Element, Element)]? {
        return Arcanus.toPairs(self)
    }
}
