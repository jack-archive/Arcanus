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
    
    public class func addConsole(_ level: SwiftyBeaver.Level = .info) {
        console.asynchronously = false
        console.minLevel = level
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
    
    public enum Error: Swift.Error {
        case badJSON
    }
    
    // MARK: Instance functionality
    var cardIndex: [Card] = []
    
    public init() {}
    /*
     public func loadCardFile(path: String) throws {
     let json = JSON(data: try Data(contentsOf: URL(fileURLWithPath: path)))
     for (_, subJson):(String, JSON) in json {
     
     // Get name, and corresponding class
     let name = subJson["name"].string!
     print(name)
     guard let cls = Card.classForName(name) else {
     log.warning("\(name) not implemented yet, skipping it.")
     continue;
     }
     
     guard let id = subJson["id"].string, let dbfId = subJson["dbfId"].int,
     let classStr = subJson["cardClass"].string, let typeStr = subJson["type"].string,
     let cost = subJson["cost"].int else {
     log.error("Bad Card JSON file while loading \(name), please fix format.")
     throw Error.badJSON
     }
     
     guard let cardClass = Card.Class.fromJSON(classStr) else {
     log.error("\(classStr) does not correspond to a class.")
     throw Error.badJSON
     }
     
     guard let type = Card.CardType.fromJSON(typeStr) else {
     log.error("\(typeStr) does not correspond to a type.")
     throw Error.badJSON
     }
     
     
     switch type {
     case .minion:
     guard let attack = subJson["attack"].int, let health = subJson["health"].int else {
     log.error("Bad Card JSON file while loading \(name), please fix format.")
     throw Error.badJSON
     }
     
     let minionCls = cls as! Minion.Type
     let instance = minionCls.init(id, name, cardClass, cost, attack, health)
     cardIndex.append(instance)
     log.info("Loaded Minion: \(instance)")
     
     case .spell: break
     case .weapon: break
     case .enchantment: break
     }
     
     
     }
     }
     */
}

func namespaceAsString() -> String {
    return String(reflecting: Hearthstone.self).components(separatedBy: ".")[0]
}

public class HearthstoneClient {
    var UI: HearthstoneUI
    var socket: Socket
    var queue: DispatchQueue
    
    public init() throws {
        UI = HearthstoneUI()
        try self.socket = Socket.create()
        self.queue = DispatchQueue(label: "Hearthstone Client")
    }
    
    public func main() throws {
        queue.async {
            do {
                log.debug("Connecting to Server")
                try self.socket.connect(to: "127.0.0.1", port: 25565)
                log.debug("Connected to Server")
                let s = try self.socket.readString()
                print(s!)
            } catch {
                
            }
        }
        //UI.startUIThread()
        //UI.mainMenu()
    }
}

public class HearthstoneGameServer {
    var port: Int
    var socket: Socket
    var sockets: [Socket] = []
    var queue: DispatchQueue
    
    public init(_ port: Int) throws {
        self.port = port
        
        try socket = Socket.create()
        queue = DispatchQueue(label: "Hearthstone Server")
    }
    
    public func startServer() {
        queue.async {
            do {
                try self.connectClients()
            } catch {
                fatalError()
            }
        }
    }
    
    func connectClients() throws {
        log.debug("Starting Server")
        try socket.listen(on: port)
        log.debug("Started Server")
        // Twice for p1 and for p2
        try sockets.append(socket.acceptClientConnection())
        log.debug("First Client Connected")
        try sockets.append(socket.acceptClientConnection())
        log.debug("Second Client Connected")
        socket.close()
        
        for soc in sockets {
            try soc.write(from: "Hello, World!\n")
        }
    }
}
