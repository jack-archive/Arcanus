// Copyright © 2017-2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CommandLineKit
import SwiftyJSON

// MARK: Commmand Line Parsing

#if os(Linux)
let EX_USAGE: Int32 = 64 // swiftlint:disable:this identifier_name
#endif

let cli = CommandLineKit.CommandLine()

let cardsPathOption = StringOption(shortFlag: "f", longFlag: "file", required: false,
                                 helpMessage: "Path to the cards.json file, will download one to cards.json if there isn't one passed.")
let outputOption = StringOption(shortFlag: "o", longFlag: "out", required: false,
                                 helpMessage: "Path to generate the file at, defaults to `cards.swift`.")

cli.addOptions(cardsPathOption, outputOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let outPath = outputOption.value ?? "cards.swift" // optional
let filePath = cardsPathOption.value ?? "cards.json" // default value

let url = "https://api.hearthstonejson.com/v1/latest/enUS/cards.json"

// Load new card file
let fileManager = FileManager.default
if !fileManager.fileExists(atPath: filePath) {
    print("Card file at \(filePath) doesn't exist, attempting downloading a copy...")
    
    let data = try Data(contentsOf: URL(string: url)!)
    let json = JSON(data: data)
    try json.description.write(toFile: filePath, atomically: true, encoding: .utf8)
    print("Saved downloaded card file to \(filePath)")
}

let json = JSON(data: try Data(contentsOf: URL(fileURLWithPath: filePath)))
for (_, subJson):(String, JSON) in json {
    guard let name = subJson["name"].string,
        let id = subJson["id"].string,
        let dbfId = subJson["dbfId"].int,
        let cls = subJson["cardClass"].string,
        let type = subJson["type"].string,
        let race = subJson["race"].string,
        let rarity = subJson["rarity"].string,
        let set = subJson["set"].string,
        let text = subJson["text"].string,
        let flavor = subJson["flavor"].string,
        let cost = subJson["cost"].int else {
            fatalError()
    }
    
    let collectible = subJson["collectible"].bool ?? false
    let mechanics = subJson["mechanics"].array ?? []
    
    switch type {
    case "MINION":
        
    default:
    }
}
