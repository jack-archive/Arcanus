// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CommandLineKit
import SwiftyBeaver
import HearthstoneCore
import cncurses

// MARK: Commmand Line Parsing

#if os(Linux)
let EX_USAGE: Int32 = 64 // swiftlint:disable:this identifier_name
#endif

let cli = CommandLineKit.CommandLine()

let logPathOption = StringOption(shortFlag: "l", longFlag: "log", required: false,
                                 helpMessage: "Path to the log file.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
                            helpMessage: "Prints a help message.")
let verbosityOption = CounterOption(shortFlag: "v", longFlag: "verbose",
                                    helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")

cli.addOptions(logPathOption, helpOption, verbosityOption)

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
let verbosity = verbosityOption.value

Hearthstone.initLog()
if logPath != nil {
    Hearthstone.addLogFile(path: logPath!)
}

HearthstoneCore.DEBUG {
    let logDirectory = "./Hearthstone Logs"
    
    let fileManager = FileManager.default
    
    if !fileManager.fileExists(atPath: logDirectory, isDirectory: nil) {
        do {
            try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Couldn't Create Logs Directory at ./\(logDirectory)")
        }
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd-HH:mm:ss"
    Hearthstone.addLogFile(path: "\(logDirectory)/log-\(dateFormatter.string(from: Date()))")
}

// MARK: UI

initscr()
start_color()

noecho()
curs_set(0)

init_pair(0, Int16(COLOR_BLACK), Int16(COLOR_GREEN))

let message = "Hello, World!"

let screenHeight = getmaxy(stdscr)
let screenWidth = getmaxx(stdscr)

clear()

let xpos = (screenWidth / 2) - (Int32(message.count) / 2)
let ypos = screenHeight / 2

log.info("(\(xpos), \(ypos))")

move(ypos, xpos)
attron(COLOR_PAIR(0))
addstr(message)
attroff(COLOR_PAIR(0))
refresh()

getch()
endwin()

/*
initscr()               // init curses
noecho()                // don't echo user input
cbreak()                // no line buffering
nonl()                  // return doesn't add new line
keypad(stdscr, true)    // give us access to arrow keys
intrflush(stdscr, false)// prevent inturrupt from messing up screen

var win = newwin(10,10,1,1)

box(win, UInt32("|"), UInt32("-"))
touchwin(win)
wrefresh(win)

getchar()

getch()
endwin()
*/
