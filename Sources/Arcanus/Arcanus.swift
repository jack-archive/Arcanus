// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

//public let globalRng = Gust(seed: UInt32(Date().timeIntervalSinceReferenceDate))

// public let log = SwiftyBeaver.self

/*
public class Arcanus {
    public enum Side {
        case client, server
    }

    public static let log = SwiftyBeaver.self
    public static var side: Side!;

}
*/
/*
public class Log {
    static var files: [String] = []

    public class func addFile(_ filename: String) {
        files.append(filename)
    }

    @discardableResult public class func debug(_ message: Any) -> String? {
        var eid: String?
        for file in files {
            if eid == nil {
                eid = LogFile.debug("\(message)", logFile: file)
            } else {
                LogFile.debug("\(message)", eventid: eid!, logFile: file)
            }
        }
        return eid
    }

    @discardableResult public class func info(_ message: Any) -> String? {
        var eid: String?
        for file in files {
            if eid == nil {
                eid = LogFile.info("\(message)", logFile: file)
            } else {
                LogFile.info("\(message)", eventid: eid!, logFile: file)
            }
        }
        return eid
    }

    @discardableResult public class func warning(_ message: Any) -> String? {
        var eid: String?
        for file in files {
            if eid == nil {
                eid = LogFile.warning("\(message)", logFile: file)
            } else {
                LogFile.warning("\(message)", eventid: eid!, logFile: file)
            }
        }
        return eid
    }

    @discardableResult public class func error(_ message: Any) -> String? {
        var eid: String?
        for file in files {
            if eid == nil {
                eid = LogFile.error("\(message)", logFile: file)
            } else {
                LogFile.error("\(message)", eventid: eid!, logFile: file)
            }
        }
        return eid
    }

     public class func critical(_ message: Any) {
        var eid: String?
        for file in files {
            if eid == nil {
                eid = LogFile.critical("\(message)", logFile: file)
            } else {
                LogFile.critical("\(message)", eventid: eid!, logFile: file)
            }
        }
    }
}
*/
public class ArcanusController: ArcanusUIController {

    // MARK: Static functionality

/*
    public static let console: ConsoleDestination = ConsoleDestination()
    public static var logFiles: [FileDestination] = []

    public class func initLog() {
    }

    public class func addConsole(_ level: SwiftyBeaver.Level = .info) {
        self.console.asynchronously = false
        self.console.minLevel = level
        log.addDestination(self.console)
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
    */

    /*
    // MARK: Instance functionality
    var ui: ArcanusUI
    var queue: DispatchQueue

    public init(ui: ArcanusUI) {
        self.ui = ui
        self.queue = DispatchQueue(label: "Arcanus Controller Queue")
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

        public static let all: [MainMenuOption] = [.playAgent, .startServer(0),
                                                    .joinServer(nil, 0), .simulate, .collection, .options]
        public static var allAsStrings: [String] { return all.map({ return $0.description }) }
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
                guard let server = try? ArcanusGameServer(port) else {
                    fatalError("Couldn't open Server")
                }
                server.startServer()

                guard let client = try? ArcanusClient(port: port) else {
                    fatalError("Couldn't connect client")
                }
            case .joinServer(let host, let port):
                guard let client = try? ArcanusClient(port: port) else {
                    fatalError("Couldn't connect client")
                }
            case .simulate: break
            case .collection: break
            case .options: break
            }
        }
    }
 */
}

public protocol ArcanusUIController: class {
    // func mainMenuOptionSelected(_ opt: ArcanusController.MainMenuOption)
}

public protocol ArcanusUI {
    // Should be Weak!
    var controller: ArcanusUIController! { get set }

    /*
    func initUI()
    func mainMenu()
    func endUI()
 */
}

/*
public class ArcanusClient {
    var socket: Socket
    var queue: DispatchQueue

    public init(server: String = "127.0.0.1", port: Int) throws {
        try self.socket = Socket.create()
        self.queue = DispatchQueue(label: "Arcanus Client")

        log.debug("Connecting to Server @ \(server) on port \(port)")
        try self.socket.connect(to: server, port: Int32(port))
        log.debug("Connected to Server @ \(server) on port \(port)")
        self.main()
    }

    func main() {
        queue.async {
            do {
                while true {
                    let str = try self.socket.readString()
                    log.debug(str!)
                }
            } catch {
                fatalError()
            }
        }
    }
}
*/
/*
public class ArcanusGameServer {
    var port: Int
    var socket: Socket
    var sockets: [Socket] = []
    var queue: DispatchQueue
    var game: Game

    enum Message {
        case startGame

        var json: JSON {
            switch self {
            case .startGame: return JSON(data: "{ msg: \"\(self.key )\" }".data(using: .utf8)!)
            }
        }

        var key: String {
            switch self {
            case .startGame: return "START_GAME"
            }
        }
    }

    public init(_ port: Int) throws {
        self.port = port

        try socket = Socket.create()
        queue = DispatchQueue(label: "Arcanus Server")
    }

    public func startServer() {
        queue.async {
            do {
                try self.connectClients()
                try self.startGame()
            } catch {
                fatalError()
            }
        }
    }

    func sendMsg(player: Int? = nil, json: JSON) throws {
        switch player {
        case nil:
            try sockets[0].write(from: json.rawData())
            try sockets[1].write(from: json.rawData())
        case 0:
            try sockets[0].write(from: json.rawData())
        case 1:
            try sockets[1].write(from: json.rawData())
        default:
            fatalError()
        }
    }

    func startGame() throws {
        try sendMsg(json: Message.startGame.json)

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
    }

}
*/
