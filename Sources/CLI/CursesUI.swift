// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Arcanus
//import cncurses
import Dispatch
import Foundation

// Not maintained rn - a project for another day

/*
public class ArcanusCursesUI : ArcanusUI {
    let minX: Int32 = 30
    let minY: Int32 = 20

    var screenWidth: Int32 = 0
    var screenHeight: Int32 = 0

    public weak var controller: ArcanusUIController!

    public init() {}

    public func initUI() {
        log.info("Starting NCurses")
        initscr()                   // init curses
        keypad(stdscr, true)
        noecho()                    // don't echo user input
        cbreak()                    // no line buffering
        nonl()                      // return doesn't add new line
        intrflush(stdscr, false)    // prevent inturrupt from messing up screen
        curs_set(0)                 // make cursor invisible
        start_color()               // use color
        log.debug("Has Color: \(has_colors())")

        init_pair(0, Int16(COLOR_WHITE), Int16(COLOR_BLUE))
        bkgd(chtype(COLOR_PAIR(0)))
        //refresh()
        //wrefresh(stdscr)
    }

    public func mainMenu() {
        let menuOptions = ["Play Agent", "Start Server", "Connect To Server", "Simulate", "Collection", "Options"]
        switch menu(title: "Main Menu", items: menuOptions) {
        case 2:
            log.info("User chose to start server")
            promptString("Port for Server")
        default:
            break
        }
    }

    enum MenuItem {
        case option(String)
        case empty
    }

    func menu(title: String, items: [String]) -> Int {
        let maxLen = Int32(items.reduce(0, { $1.count > $0 ? $1.count : $0 }))

        checkScreenBounds()
        let height: Int32 = Int32(items.count) + 2
        let width: Int32 = (maxLen + 14)
        let xpos = (screenWidth / 2) - (width / 2)
        let ypos = (screenHeight / 2) - (height / 2)

        let win = newwin(height, width, ypos, xpos)
        refresh()

        init_pair(1, Int16(COLOR_RED), Int16(COLOR_WHITE))
        init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
        init_pair(3, Int16(COLOR_WHITE), Int16(COLOR_RED))

        wbkgd(win, chtype(COLOR_PAIR(2)))
        box(win, 0, 0)
        wmove(win, 0, (width / 2) - ((Int32(title.count) + 4) / 2))
        waddstr(win, "|")
        wattron(win, COLOR_PAIR(1))
        waddstr(win, " \(title) ")
        wattron(win, COLOR_PAIR(2))
        waddstr(win, "|")

        var choice = 0
        while (true) {
            checkScreenBounds()
            log.verbose("Choice: \(choice)")
            wattron(win, COLOR_PAIR(2))
            for (k, item) in items.enumerated() {
                let text = "< \(item) >"
                wmove(win, Int32(k) + 1, (width / 2) - (Int32(text.count) / 2))
                if k == choice {
                    wattron(win, COLOR_PAIR(3))
                } else {
                    wattron(win, COLOR_PAIR(2))
                }
                waddstr(win, text)
            }
            wrefresh(win)

            let c = getch()
            log.verbose("c: \(c)")
            switch c {
            case KEY_UP:
                if choice > 0 {
                    choice -= 1
                }
            case KEY_DOWN:
                if choice < (items.count - 1) {
                    choice += 1
                }
            case KEY_ENTER, 13:
                log.debug("User Selected \(choice)")
                wborder(win, 32, 32, 32, 32, 32, 32, 32, 32)
                wbkgd(win, chtype(COLOR_PAIR(0)))
                wclear(win)
                wrefresh(win)
                delwin(win)
                return choice
            default:
                continue
            }
        }
    }

    func promptString(_ question: String, title: String = "Prompt") -> String {
        checkScreenBounds()
        let height: Int32 = 5
        let width: Int32 = Int32(question.count) + 14
        let xpos = (screenWidth / 2) - (width / 2)
        let ypos = (screenHeight / 2) - (height / 2)

        let win = newwin(height, width, ypos, xpos)
        refresh()

        init_pair(1, Int16(COLOR_RED), Int16(COLOR_WHITE))
        init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
        init_pair(3, Int16(COLOR_WHITE), Int16(COLOR_RED))

        wbkgd(win, chtype(COLOR_PAIR(2)))
        box(win, 0, 0)
        wmove(win, 0, (width / 2) - ((Int32(title.count) + 4) / 2))
        waddstr(win, "|")
        wattron(win, COLOR_PAIR(1))
        waddstr(win, " \(title) ")
        wattron(win, COLOR_PAIR(2))
        waddstr(win, "|")

        wmove(win, 2, 2)
        let str = "\(question): "
        waddstr(win, str)
        wrefresh(win)

        var input = ""
        while true {
            log.debug("Input: \(input)")
            wmove(win, 2, 3 + Int32(str.count))
            wattron(win, COLOR_PAIR(3))
            waddstr(win, input)
            curs_set(1)
            wrefresh(win)

            let c = getch()
            log.debug("c: \(c)")
            switch c {
            case KEY_ENTER, 13:
                wborder(win, 32, 32, 32, 32, 32, 32, 32, 32)
                wbkgd(win, chtype(COLOR_PAIR(0)))
                wclear(win)
                wrefresh(win)
                delwin(win)
                log.debug("return")
                return input
            case KEY_BACKSPACE:
                input = String(input.dropLast())
            default:
                if let ch = UnicodeScalar(Int(c)) {
                    let char = Character(ch)
                    log.debug("Char: \(char)")
                    input.append(char)
                } else {
                    log.warning("No Unicode Value")
                }
            }
        }
    }

    func optionsScreen() {
        checkScreenBounds()
        let height: Int32 = 30
        let width: Int32 = 80
        let xpos = (screenWidth / 2) - (width / 2)
        let ypos = (screenHeight / 2) - (height / 2)

        let title = "Options"
        let win = newwin(height, width, ypos, xpos)
        refresh()

        init_pair(1, Int16(COLOR_RED), Int16(COLOR_WHITE))
        init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
        init_pair(3, Int16(COLOR_WHITE), Int16(COLOR_RED))

        wbkgd(win, chtype(COLOR_PAIR(2)))
        box(win, 0, 0)
        wmove(win, 0, (width / 2) - ((Int32(title.count) + 4) / 2))
        waddstr(win, "|")
        wattron(win, COLOR_PAIR(1))
        waddstr(win, " \(title) ")
        wattron(win, COLOR_PAIR(2))
        waddstr(win, "|")
        wrefresh(win)

        getch()
    }

    public func endUI() {
        endwin()
        log.info("Ended NCurses")
    }

    func refreshScreenBounds() {
        screenHeight = getmaxy(stdscr)
        screenWidth = getmaxx(stdscr)
    }

    func checkScreenBounds() {
        refreshScreenBounds()
        if screenWidth < minX || screenHeight < minY {
            log.error("Terminal window too small (\(screenWidth), \(screenHeight)). Please Resize.")
            print("Terminal window too small (\(screenWidth), \(screenHeight)). Please Resize.")
            while (true) {
                refreshScreenBounds()
                if screenWidth < minX || screenHeight < minY {
                    continue
                } else {
                    log.info("Screen size fixed")
                    return
                }
            }
        }
    }
}
*/
