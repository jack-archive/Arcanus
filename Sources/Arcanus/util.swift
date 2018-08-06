// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

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
