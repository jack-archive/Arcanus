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
    
    public enum MainMenuOption: CustomStringConvertible {
        case playAgent
        case startServer(Int)
        case joinServer(String?, Int)
        case simulate
        case collection
        case options
        
        public var description: String {
            switch self {
            case .playAgent: return "Play Agents"
            case .startServer: return "Start Server"
            case .joinServer: return "Join Server"
            case .simulate: return "Simulate"
            case .collection: return "Collection"
            case .options: return "Options"
            }
        }
        
        static let all: [MainMenuOption] = [.playAgent, .startServer(0), .joinServer(nil, 0), .simulate, .collection, .options]
        static var allAsStrings: [String] { return all.map({ return $0.description }) }
    }
    
    public func start() {
        ui.initUI()
        ui.mainMenu()
        ui.endUI()
    }
    
    public func mainMenuOptionSelected(_ opt: MainMenuOption) {
        queue.async {
            switch opt {
            case .playAgent: break
            case .startServer(let port):
                guard let server = try? HearthstoneGameServer(port) else {
                    fatalError("Couldn't open Server")
                }
                server.startServer()
                
                guard let client = try? HearthstoneClient(port: port) else {
                    fatalError("Couldn't connect client")
                }
                
            case .joinServer(let host, let port):
                guard let client = try? HearthstoneClient(port: port) else {
                    fatalError("Couldn't connect client")
                }
            case .simulate: break
            case .collection: break
            case .options: break
            }
        }
    }
}

public protocol HearthstoneUIController: class {
    func mainMenuOptionSelected(_ opt: Hearthstone.MainMenuOption)
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
    
    public init(server: String = "127.0.0.1", port: Int) throws {
        try self.socket = Socket.create()
        self.queue = DispatchQueue(label: "Hearthstone Client")
        
        log.debug("Connecting to Server @ \(server) on port \(port)")
        try self.socket.connect(to: server, port: Int32(port))
        log.debug("Connected to Server @ \(server) on port \(port)")
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
