// Copyright © 2017 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

print("Hello, World!")

let json = """
[
{"artist":"Dan Brereton","attack":3,"cardClass":"NEUTRAL","collectible":true,"cost":2,"dbfId":216,"faction":"HORDE","health":2,"howToEarnGolden":"Unlocked at Hunter Level 57.","id":"CS2_172","name":"Bloodfen Raptor","race":"BEAST","rarity":"FREE","set":"CORE","type":"MINION"},
{"artist":"Brian Despain","attack":3,"cardClass":"NEUTRAL","collectible":true,"cost":4,"dbfId":635,"faction":"HORDE","flavor":"Sen'jin Village is nice, if you like trolls and dust.","health":5,"howToEarnGolden":"Unlocked at Rogue Level 59.","id":"CS2_179","mechanics":["TAUNT"],"name":"Sen'jin Shieldmasta","rarity":"FREE","set":"CORE","text":"<b>Taunt</b>","type":"MINION"},
{"artist":"Raymond Swanland","cardClass":"PRIEST","collectible":true,"cost":2,"dbfId":1367,"howToEarn":"Unlocked at Level 1.","howToEarnGolden":"Unlocked at Level 36.","id":"CS2_234","name":"Shadow Word: Pain","playRequirements":{"REQ_MINION_TARGET":0,"REQ_TARGET_MAX_ATTACK":3,"REQ_TARGET_TO_PLAY":0},"rarity":"FREE","set":"CORE","text":"Destroy a minion with 3 or less Attack.","type":"SPELL"}
]
"""
/*
var data = json.data(using: .utf8)

do {
    let stats = try JSONDecoder().decode(CardsJson.self, from: data!)
    print(stats)
} catch {
    print(error)
}

*/
/*
var s1: Stats = .minion(MinionStats(dbfId: 1, name: "Hello", attack: 1, health: 21))

s1.cardStats.name = "Sup"

print(s1)
*/

var g = Game(CLIController(), CLIController())
g.start()
