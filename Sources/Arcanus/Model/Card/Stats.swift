// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Vapor



struct StatsContainer: Content {
    var stats: CardStats

    init(from decoder: Decoder) throws {
        throw Abort(.badRequest, reason: "Not Decodable")
    }

    init(stats: CardStats) {
        self.stats = stats
    }

    func encode(to encoder: Encoder) throws {
        try self.stats.encode(to: encoder)
    }
}
