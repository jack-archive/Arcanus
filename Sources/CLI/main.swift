// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Arcanus
import cncurses
import CommandLineKit
import Foundation
import SwiftyBeaver

Log.addFile("log.log")
Log.addFile("log2.log")

Log.debug("Hello World!")

// MARK: Commmand Line Parsing
/*
#if os(Linux)
let EX_USAGE: Int32 = 64 // swiftlint:disable:this identifier_name
#endif

let cli = CommandLineKit.CommandLine()

// swiftlint:disable line_length
let serverOption = BoolOption(shortFlag: "s", longFlag: "server", helpMessage: "Start a server.")

let logPathOption = StringOption(shortFlag: "l",
                                 longFlag: "log",
                                 required: false,
                                 helpMessage: "Path to the log file.")
let cardsPathOption = StringOption(shortFlag: "c",
                                   longFlag: "cardfile",
                                   required: false,
                                   helpMessage: "Path to the cards.json file.")
let helpOption = BoolOption(shortFlag: "h",
                            longFlag: "help",
                            helpMessage: "Prints a help message.")
let verbosityOption = CounterOption(shortFlag: "v",
                                    longFlag: "verbose",
                                    helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")
// swiftlint:enable line_length

cli.addOptions(serverOption, logPathOption, cardsPathOption, helpOption, verbosityOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.wasSet {
    cli.printUsage()
    exit(0)
}

let logPath = logPathOption.value // optional
let cardPath = cardsPathOption.value ?? "cards.json" // default value
let verbosity = verbosityOption.value

ArcanusController.initLog()

Arcanus.DEBUG {
    let logDirectory = "./Arcanus Logs"

    let fileManager = FileManager.default
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd-HH:mm:ss"

    // try! fileManager.removeItem(atPath: "\(logDirectory)/last")
    ArcanusController.addLogFile(path: "\(logDirectory)/last", minLevel: .debug)
    ArcanusController.addLogFile(path: "\(logDirectory)/log-\(dateFormatter.string(from: Date()))")

    // swiftlint:disable identifier_name
    let COLOR_RED = "\u{001b}[31;1m"
    let COLOR_RESET = "\u{001b}[0m"
    // swiftlint:enable identifier_name

    // swiftlint:disable line_length
    // Use `tail -f Arcanus\ Logs/last` to watch a constant log of all runs live
    log.info("\(COLOR_RED)================================================================================\(COLOR_RESET)")
    log.info("\(COLOR_RED)========================== NEW LOG \(dateFormatter.string(from: Date())) ===========================\(COLOR_RESET)")
    log.info("\(COLOR_RED)================================================================================\(COLOR_RESET)")
    // swiftlint:enable line_length

    if !fileManager.fileExists(atPath: logDirectory, isDirectory: nil) {
        do {
            try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Couldn't Create Logs Directory at ./\(logDirectory)")
        }
    }
}

if logPath != nil {
    ArcanusController.addLogFile(path: logPath!)
}

ArcanusController.addConsole(.verbose)

if serverOption.value {
    log.info("Server-Side")
    Arcanus.serverMain()
} else {
    log.info("Client-Side")
    Arcanus.clientMain()
}

/*
let hs = ArcanusController(ui: ArcanusCLI())
hs.start()
*/
/*
let server = try ArcanusGameServer(25565)
server.startServer()

sleep(1)

let client1 = try ArcanusClient()
let client2 = try ArcanusClient()

try client1.main()
try client2.main()

sleep(10)
*/
 */
