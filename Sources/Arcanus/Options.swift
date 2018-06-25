// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Option {
    enum Value {
        case int(Int)
        case bool(Bool)
        case string(String)
    }

    var id: Int
    var value: Value
    var title: String
    var description: String

    static var id = 0
    static func getNextID() -> Int {
        id += 1
        return id
    }

    init(_ value: Value, _ title: String, _ description: String) {
        self.id = Option.getNextID()
        self.value = value
        self.title = title
        self.description = description
    }

    // swiftlint:disable line_length
    static let startingHandSize: Option = Option(.int(4),
                                                 "Starting Hand Size",
                                                 "Starting hand size for the player going first")
    static let extraCardsForGoingSecond: Option = Option(.int(1),
                                                         "Extra Card For Going Second",
                                                         "How many extra cards the player going second gets in their starting hand on top of the starting hand size for the player going first")
    static let coinForGoingSecond: Option = Option(.bool(true),
                                                   "Second player gets `The Coin`",
                                                   "Whether or not the player going second get a copy of `The Coin`")
    // swiftlint:enable line_length
}
