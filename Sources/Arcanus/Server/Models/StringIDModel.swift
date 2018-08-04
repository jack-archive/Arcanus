// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftKueryORM

protocol StringIDModel: Model {
    static func get(_ id: String) throws -> Self?
}

fileprivate struct IdParam: QueryParams {
    let id: String
    init(_ id: String) {
        self.id = id
    }
}

extension StringIDModel {
    static func get(_ id: String) throws -> Self? {
        var rv: Self?
        var error: RequestError?
        Self.findAll(matching: IdParam(id)) { (results: [Self]?, err: RequestError?) in
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
            return rv
        } else {
            throw ArcanusError.kituraError(error!)
        }
    }
}
