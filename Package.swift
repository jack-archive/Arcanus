// swift-tools-version:4.0
// Copyright © 2018 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PackageDescription

let package = Package(
    name: "Hearthstone",
    products: [
        .library(name: "HearthstoneCore", targets: ["HearthstoneCore"]),
        .executable(name: "Hearthstone", targets: ["Hearthstone"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.5.2"),
        // .package(url: "https://github.com/jmmaloney4/CommandLine.git", from: "3.1.1"),
        .package(url: "https://github.com/jatoben/CommandLine.git", .branch("master")),
        .package(url: "https://github.com/evgenyneu/SigmaSwiftStatistics.git", from: "7.0.2"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.0"),
        .package(url: "https://github.com/ClibSwift/ncurses.git", .branch("master")),
        .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.0"),
        
        /*
        
        .package(url: "https://github.com/jmmaloney4/Squall.git", from: "1.2.3"),
        .package(url: "https://github.com/davecom/SwiftPriorityQueue.git", from: "1.2.1"),
        .package(url: "https://github.com/jmmaloney4/Weak.git", from: "0.1.0"),
        
        */
    ],
    targets: [
        .target(name: "Hearthstone", dependencies: [ "HearthstoneCore", "SwiftyBeaver", "CommandLine"]),
        .target(name: "HearthstoneCore", dependencies: [ "SwiftyBeaver", "SigmaSwiftStatistics", "Socket", "SwiftyJSON" ])
    ],
    swiftLanguageVersions: [4]
)

