// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import cncurses
import Dispatch

public class HearthstoneUI {
    let minX: Int32 = 30
    let minY: Int32 = 20
    
    var screenWidth: Int32 = 0
    var screenHeight: Int32 = 0
    
    var queue: DispatchQueue
    // var group: DispatchGroup
    // var end: Bool = false
    
    public init() {
        queue = DispatchQueue(label: "Hearthstone UI")
        // group = DispatchGroup()
    }
    
    public func startUIThread() {
        queue.sync {
            initscr()                   // init curses
            keypad(stdscr, true)
            noecho()                    // don't echo user input
            cbreak()                    // no line buffering
            nonl()                      // return doesn't add new line
            intrflush(stdscr, false)    // prevent inturrupt from messing up screen
            curs_set(0)                 // make cursor invisible
            start_color()               // use color
            log.info("Has Color: \(has_colors())")
        }
    }
    
    public func mainMenu() {
        queue.sync {
            let menuOptions = ["Play Local", "Play Agent", "Play over Network", "Simulate", "Collection", "Options"]
            switch mainMenu(title: "Main Menu", items: menuOptions) {
            default:
                optionsScreen()
                break
            }
        }
        endUI()
    }
    
    enum MenuItem {
        case option(String)
        case empty
    }
    
    func mainMenu(title: String, items: [String]) -> Int {
        let maxLen = Int32(items.reduce(0, { $1.count > $0 ? $1.count : $0 }))
        
        refreshScreenBounds()
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
        
        wbkgd(win, UInt32(COLOR_PAIR(2)))
        box(win, 0, 0)
        wmove(win, 0, (width / 2) - ((Int32(title.count) + 4) / 2))
        waddstr(win, "|")
        wattron(win, COLOR_PAIR(1))
        waddstr(win, " \(title) ")
        wattron(win, COLOR_PAIR(2))
        waddstr(win, "|")
        
        var choice = 0
        while (true) {
            log.debug("Choice: \(choice)")
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
            log.debug("c: \(c)")
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
                return choice
            default:
                continue
            }
        }
    }

    func optionsScreen() {
        refreshScreenBounds()
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

        wbkgd(win, UInt32(COLOR_PAIR(2)))
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
    
    func endUI() {
        queue.sync {
            endwin()
            log.info("Ended NCurses")
        }
    }
    
    func refreshScreenBounds() {
        screenHeight = getmaxy(stdscr)
        screenWidth = getmaxx(stdscr)
    }
    
    func checkScreenBounds() {
        if screenWidth < minX || screenHeight < minY {
            log.error("Terminal window too small. Please Resize.")
            print("Terminal window too small. Please Resize.")
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
