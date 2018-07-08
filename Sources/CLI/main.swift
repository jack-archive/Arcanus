// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Arcanus
import CommandLineKit
import Foundation
import LoggerAPI

// MARK: Commmand Line Parsing

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

try Arcanus.DEBUG {
    let logDirectory = "./Logs"
    let fileManager = FileManager.default
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd-HH:mm:ss"

    if !fileManager.fileExists(atPath: logDirectory, isDirectory: nil) {
        try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    if logPath != nil {
        try ArcanusLog.setLogFile(logPath!)
    } else {
        try ArcanusLog.setLogFile("./log.log")
    }

    // swiftlint:disable line_length
    // Use `tail -f Arcanus\ Logs/last` to watch a constant log of all runs live
    Log.info("================================================================================".red)
    Log.info("========================== ".red + "NEW LOG \(dateFormatter.string(from: Date()))".white.bold + " ===========================".red)
    Log.info("================================================================================".red)
    // swiftlint:enable line_length
}

if serverOption.value {
    Arcanus.serverMain()
} else {
    Arcanus.clientMain()
}
