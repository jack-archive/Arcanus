// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Arcanus
import CommandLineKit
import Foundation
import LoggerAPI

#if os(Linux)
let EX_USAGE: Int32 = 64 // swiftlint:disable:this identifier_name
#endif

// MARK: Commmand Line Parsing

let cli = CommandLineKit.CommandLine()

// swiftlint:disable line_length
let serverOption = BoolOption(shortFlag: "s", longFlag: "server", helpMessage: "Start as a server.")
let databasePathOption = StringOption(shortFlag: "d",
                                      longFlag: "database",
                                      required: false,
                                      helpMessage: "Path to the database file.")

let logPathOption = StringOption(shortFlag: "l",
                                 longFlag: "log",
                                 required: false,
                                 helpMessage: "Path to the log file.")
let logConsoleOption = BoolOption(longFlag: "console",
                                  required: false,
                                  helpMessage: "Log to the console.")
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

cli.addOptions(serverOption, databasePathOption, logPathOption, logConsoleOption, cardsPathOption, helpOption, verbosityOption)

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

var console = logConsoleOption.value
let logPath = logPathOption.value // optional
let dbPath = databasePathOption.value // ^
let cardPath = cardsPathOption.value ?? "cards.json" // default value
let verbosity = verbosityOption.value

if console && logPath != nil {
    ArcanusLog.setConsole()
    Log.warning("Both log file and console option set, log file overriding.")
    console = false
}

if console {
    ArcanusLog.setConsole()
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyyMMdd-HH:mm:ss"

if logPath != nil {
    try ArcanusLog.setLogFile(logPath!)
} else {
    ArcanusLog.setConsole()
    //try ArcanusLog.setLogFile("./log.log")
}

// swiftlint:disable line_length
// Use `tail -f log.log` to watch a constant log of all runs live
Log.info("================================================================================".red)
Log.info("========================== ".red + "NEW LOG \(dateFormatter.string(from: Date()))".white.bold + " ===========================".red)
Log.info("================================================================================".red)
// swiftlint:enable line_length

if serverOption.value {
    Arcanus.serverMain(dbPath: dbPath)
} else {
    Arcanus.clientMain()
}
