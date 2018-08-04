//
//  Test.swift
//  Arcanus
//
//  Created by Jack Maloney on 8/4/18.
//

import Foundation
import SwiftKueryORM
import LoggerAPI
import KituraContracts

final class Test: Model {
    var id: Int?
    var relate: Int
    
    init(id: Int, relate: Int) {
        //self.id = id
        self.relate = relate
        
        self.save { (test, err) in
            if err != nil {
                Log.error(err!.localizedDescription)
                return
            }
            Log.info("TEST: \(self.id)")
        }
    }
}
