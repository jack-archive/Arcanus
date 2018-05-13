// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import cncurses
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
            keypad(stdscr, true)        // give us access to arrow keys
            intrflush(stdscr, false)    // prevent inturrupt from messing up screen
            curs_set(0)                 // make cursor invisible
            start_color()               // use color
            log.info("Has Color: \(has_colors())")
        }
    }
    
    public func mainMenu() {
        queue.sync {
            refreshScreenBounds()
            checkScreenBounds()
            let height: Int32 = 10
            let width: Int32 = 20
            let xpos = (screenWidth / 2) - (width / 2)
            let ypos = (screenHeight / 2) - (height / 2)
            
            let win = newwin(height, width, ypos, xpos)
            refresh()
            
            init_pair(0, Int16(COLOR_RED), Int16(COLOR_GREEN))
            
            attron(COLOR_PAIR(0))
            box(win, 0, 0)
            wmove(win, 1, 1)
            waddstr(win, "Hola!")
            wrefresh(win)
            
            getch()
        }
        endUI()
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
