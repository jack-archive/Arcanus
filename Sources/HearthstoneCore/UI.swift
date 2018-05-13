// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Darwin.ncurses
import Dispatch

public class HearthstoneUI {
    let minX: Int32 = 40
    let minY: Int32 = 30
    
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
            let menuOptions = ["Play Local", "Play Agent", "Play over Network", "Simulate", "Collection"]
            
            buildMenu(title: "Main Menu", options: menuOptions)
            
            //init_pair(1, Int16(COLOR_RED), Int16(COLOR_GREEN))
            /*
             wattron(win, COLOR_PAIR(1))
             wbkgd(win, UInt32(COLOR_PAIR(1)))
             box(win, 0, 0)
             wmove(win, 1, 1)
             waddstr(win, "Hola!")
             wrefresh(win)
             wattroff(win, COLOR_PAIR(1))
             */
            //getch()
        }
        endUI()
    }
    
    func buildMenu(title: String, options: [String]) -> Int {
        let maxLen = Int32(options.reduce(0, { return $1.count > $0 ? $1.count : $0 }))
        
        refreshScreenBounds()
        checkScreenBounds()
        let height: Int32 = Int32(options.count) + 2
        let width: Int32 = (maxLen + 14)
        let xpos = (screenWidth / 2) - (width / 2)
        let ypos = (screenHeight / 2) - (height / 2)
        
        let win = newwin(height, width, ypos, xpos)
        refresh()
        keypad(stdscr, true)
        
        init_pair(1, Int16(COLOR_RED), Int16(COLOR_WHITE))
        init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
        init_pair(3, Int16(COLOR_WHITE), Int16(COLOR_RED))
        
        wbkgd(win, UInt32(COLOR_PAIR(1)))
        box(win, 0, 0)
        wmove(win, 0, (width / 2) - (Int32(title.count) / 2))
        waddstr(win, title)
        
        var choice = 0
        while (true) {
            log.debug("Choice: \(choice)")
            wattron(win, COLOR_PAIR(2))
            for (k, item) in options.enumerated() {
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
                if choice < (options.count - 1) {
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
    
    func mainUIFunc() {
        
        let message = "Hello, World!"
        
        
        
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
