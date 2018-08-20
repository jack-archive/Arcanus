//
//  Deckstring.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/19/18.
//

import Foundation
import VarInt

enum VarIntError: Error {
    case base64DecodeFailed
}

// See https://www.reddit.com/r/hearthstone/comments/6f2xyk/how_to_encodedecode_deck_codes/
// for info on how the encoding works
func decodeBase64VarIntString(_ input: String) throws -> [UInt64] {
    guard var data = Data(base64Encoded: input) else {
        throw VarIntError.base64DecodeFailed
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

func encodeBase64VarIntString(_ input: [UInt64]) -> String {
    var bytes: [UInt8] = []
    for val in input {
        bytes.append(contentsOf: putUVarInt(val))
    }

    return Data(bytes: bytes).base64EncodedString()
}
