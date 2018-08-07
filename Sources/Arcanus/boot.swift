// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Routing
import Vapor

/// Called after your application has initialized.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#bootswift)
public func boot(_ app: Application) throws {
    // your code here
    
    let db = try app.newConnection(to: .sqlite).wait()
    let decoded = try decodeDeckstring("AAECAR8GycIC/eoC4fUC8PUCoIADzIEDDPsFlwjR4QKf9QKl9QLg9QLi9QLv9QK5+AK8/AL2/QKJgAMA")
    print(decoded)
    let deck = try Deck.init(fromDeckstring: decoded.map({ DbfID($0) }))
    print("Init:", deck.toDbfIDArray())
    print("Saved:", try deck.save(on: db).wait().toDbfIDArray())
    print("Deckstring:", deck.toDeckstringArray())
}
