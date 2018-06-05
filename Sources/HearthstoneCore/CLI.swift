// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Rainbow

public class HearthstoneCLI : HearthstoneUI {
    public var controller: HearthstoneUIController!
    
    public init() {}
    
    public func initUI() {
        
    }
    
    public func mainMenu() {
        let rv = menu(title: "Main Menu", options: Hearthstone.MainMenuOptions.allAsStrings)
    }
    
    public func endUI() {
        
    }
    
    func boolPrompt(_ prompt:String) -> Bool? {
        while true {
            print(prompt, terminator: "? ")
            print("[y/n]: ".bold, terminator: "")
            
            guard let line = readLine() else {
                return nil
            }
            
            switch line {
            case "y", "Y", "yes", "Yes","YES":
                return true
            case "n", "N", "no", "No","NO":
                return false
            default:
                continue;
            }
        }
    }
    
    func menu(title: String? = nil, _ options: String...) -> Int {
        return menu(title: title, options: options)
    }
    
    func menu(title: String? = nil, options: [String]) -> Int {
        if title != nil {
            print("==> ".blue + title!.bold)
        }
        
        for (i, opt) in options.enumerated() {
            print("\(i) ".bold + opt)
        }
        while true {
            print("[0-\(options.count - 1)]: ".bold, terminator: "")
            guard let line = readLine() else {
                continue
            }
            
            let rv = Int(line)
            if rv == nil || rv! < 0 || rv! > options.count - 1 {
                continue
            } else {
                return rv!
            }
        }
    }
    
}
