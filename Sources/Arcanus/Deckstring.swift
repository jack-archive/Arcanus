// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import VarInt

// See https://www.reddit.com/r/hearthstone/comments/6f2xyk/how_to_encodedecode_deck_codes/
// for info on how the encoding works
public func decodeDeckstring(_ input: String) throws -> [UInt64] {
    guard var data = Data(base64Encoded: input) else {
        throw ArcanusError.failedToConvertData
    }

    // Setup bytes to hold data
    var bytes: [UInt8] = Array(repeating: 0, count: data.count)
    data.copyBytes(to: UnsafeMutablePointer(&bytes), count: data.count)
    var ints: [UInt64] = []

    while true {
        let (int, count) = uVarInt(bytes)
        if count <= 0 {
            break
        }
        ints.append(int)
        bytes.removeFirst(count)
    }

    return ints
}

public func encodeDeckstring(_ input: [UInt64]) -> String {
    var bytes: [UInt8] = []
    for val in input {
        bytes.append(contentsOf: putUVarInt(val))
    }

    return Data(bytes: bytes).base64EncodedString()
}
