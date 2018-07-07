// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Arcanus
import Foundation
import Rainbow

public class ArcanusCLI: ArcanusUI {
    public var controller: ArcanusUIController!

    public init() {}

    public func initUI() {
    }
    /*
    public func mainMenu() {
        let option = ArcanusController.MainMenuOption.all[menu(title: "Main Menu",
     options: ArcanusController.MainMenuOption.allAsStrings)]
        switch option {
        case .playAgent: break
        case .startServer:
            let port = intPrompt("Port", 49152..<65535, def: 55555)
            log.debug("Port: \(port)")
            controller.mainMenuOptionSelected(.startServer(port))
            sleep(10)
        case .joinServer:
            let hostname = stringPrompt("Hostname", def: "127.0.0.1")
            let port = intPrompt("Port", 49152..<65535, def: 55555)
            controller.mainMenuOptionSelected(.joinServer(hostname, port))
            sleep(8)
        case .simulate: break
        case .collection: break
        case .options: break
        }

    }
 */

    public func endUI() {
    }

    func boolPrompt(_ prompt: String) -> Bool? {
        while true {
            print(prompt, terminator: "? ")
            print("[y/n]: ".bold, terminator: "")

            guard let line = readLine() else {
                return nil
            }

            switch line {
            case "y", "Y", "yes", "Yes", "YES":
                return true
            case "n", "N", "no", "No", "NO":
                return false
            default:
                continue
            }
        }
    }

    func intPrompt(arrow: Bool = true,
                   _ prompt: String,
                   _ range: Range<Int> = Range<Int>(Int.min...Int.max),
                   def: Int? = nil) -> Int {
        while true {
            if arrow {
                print("==>".blue, terminator: " ")
            }

            print(prompt.bold, terminator: " ")

            if def != nil {
                print("(default: \(def!))", terminator: " ")
            }

            log.debug("Range: \(range)")

            if range.lowerBound != Int.min && range.upperBound != Int.max {
                print("[\(range.lowerBound)-\(range.upperBound)]:".bold, terminator: " ")
            }

            guard let line = readLine() else {
                continue
            }

            if line == "" && def != nil {
                return def!
            }

            let rv = Int(line)
            if rv == nil || rv! < range.lowerBound || rv! > range.upperBound {
                continue
            } else {
                return rv!
            }
        }
    }

    func stringPrompt(arrow: Bool = true, _ prompt: String, def: String? = nil) -> String {
        while true {
            if arrow {
                print("==>".blue, terminator: " ")
            }

            print(prompt.bold, terminator: " ")

            if def != nil {
                print("(default: \(def!))", terminator: "")
            }
            print(":".bold, terminator: "")

            guard let line = readLine() else {
                continue
            }

            if line == "" && def != nil {
                return def!
            }

            return line
        }
    }

    func menu(title: String? = nil, _ options: String...) -> Int {
        return self.menu(title: title, options: options)
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
