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

public class Hearthstone: HearthstoneUIController {
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
        dest.minLevel = minLevel
        logFiles.append(dest)
        log.addDestination(dest)
        log.info("Logging to file at \(path)")
    }
    
    public enum Error: Swift.Error {
        case badJSON
    }
    
    // MARK: Instance functionality
    var ui: HearthstoneUI
    var queue: DispatchQueue
    
    public init(ui: HearthstoneUI) {
        self.ui = ui
        self.queue = DispatchQueue(label: "Hearthstone Controller Queue")
        self.ui.controller = self
    }
    
    enum MainMenuOptions: CustomStringConvertible {
        case playAgent
        case startServer(port: Int)
        case joinServer
        case simulate
        case collection
        case options
        
        var description: String {
            switch self {
            case .playAgent: return "Play Agents"
            case .startServer: return "Start Server"
            case .joinServer: return "Join Server"
            case .simulate: return "Simulate"
            case .collection: return "Collection"
            case .options: return "Options"
            }
        }
        
        static let all: [MainMenuOptions] = [.playAgent, .startServer(port: 0), .joinServer, .simulate, .collection, .options]
        static var allAsStrings: [String] { return all.map({ return $0.description }) }
    }
    
    public func start() {
        ui.initUI()
        ui.mainMenu()
        ui.endUI()
    }
    
    public func startServer(port: Int) {
        queue.async {
            
        }
    }
}

public protocol HearthstoneUIController: class {
    func startServer(port: Int)
}

public protocol HearthstoneUI {
    // Should be Weak!
    var controller: HearthstoneUIController! { get set }
    
    
    
    func initUI()
    func mainMenu()
    func endUI()
}

func namespaceAsString() -> String {
    return String(reflecting: Hearthstone.self).components(separatedBy: ".")[0]
}

public class HearthstoneClient {
    var socket: Socket
    var queue: DispatchQueue
    
    public init() throws {
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
