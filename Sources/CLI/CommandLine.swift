// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Rainbow

class CLIController: PlayerController {
    var game: Game!
    var side: Side!

    func getDeck() -> [Card] {
        return [BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor(), BloodfenRaptor()]
    }

    func chooseAction() -> PlayerAction {
        var options: [PlayerAction] = [.playCard(fromHand: 0, toBoard: 0), .endTurn, .combat(from: 0, to: 0)]
        var strings = options.map({ String(describing: $0) })

        return options[optionPrompt(strings)]
    }

    func boolPrompt(_ prompt: String) -> Bool? {
        while true {
            print(prompt, terminator: "? [y/n]: ")

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

    func printOptionList(_ options: [String]) {
        options.forEach { opt in
            print(opt)
        }
    }

    func optionPrompt(_ options: [String]) -> Int {
        self.printOptionList(options)

        while true {
            print("[0-\(options.count - 1)]", terminator: ": ")
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
