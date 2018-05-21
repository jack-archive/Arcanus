// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftyBeaver
import Socket
import SwiftyJSON

public let log = SwiftyBeaver.self
//public let globalRng = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

public func DEBUG(_ code: () -> Void) {
    if _isDebugAssertConfiguration() {
        code()
    }
}

public class Hearthstone {
    // MARK: Static functionality
    public static let console: ConsoleDestination = ConsoleDestination()
    public static var logFiles: [FileDestination] = []
    
    public class func initLog() {
        
    }

    public class func addConsole() {
        console.asynchronously = false
        console.minLevel = .info
        log.addDestination(console)
        log.info("Logging to Console")
    }
    
    public class func addLogFile(path: String, minLevel: SwiftyBeaver.Level = .verbose) {
        let dest = FileDestination()
        dest.asynchronously = false
        dest.logFileURL = URL(fileURLWithPath: path)
        dest.minLevel = .verbose
        logFiles.append(dest)
        log.addDestination(dest)
        log.info("Logging to file at \(path)")
    }
    
    // MARK: Instance functionality
    var cardIndex: [Card] = []
    
    public init() {}
    
    public func loadCardFile(path: String) throws {
        let json = JSON(data: try Data(contentsOf: URL(fileURLWithPath: path)))
        for (_, subJson):(String, JSON) in json {
            let name = subJson["name"].string!
            print(name)
            let cls = Card.classForName(name)!
            let instance = cls.init()
            print(instance.name)
        }
    }
}

func namespaceAsString() -> String {
    return String(reflecting: Hearthstone.self).components(separatedBy: ".")[0]
}

public class HearthstoneClient {
    var UI: HearthstoneUI
    public init() {
        UI = HearthstoneUI()
    }
    
    public func main() {
        UI.startUIThread()
        UI.mainMenu()
    }
    
}
