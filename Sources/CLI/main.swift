import Arcanus
import Foundation
import Service
import Vapor
import CommandLineKit

let serverOption = BoolOption(shortFlag: "s", longFlag: "server", helpMessage: "Start as a server.")

let databasePathOption = StringOption(shortFlag: "d",
                                      longFlag: "database",
                                      required: false,
                                      helpMessage: "Path to the database file.")

let helpOption = BoolOption(shortFlag: "h",
                            longFlag: "help",
                            helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(serverOption, 
               databasePathOption, 
               helpOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.wasSet {
    cli.printUsage()
    exit(0)
}


do {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()
    
    try Arcanus.configure(&config, &env, &services, databasePathOption.value)
    
    let app = try Application(config: config,
                              environment: env,
                              services: services)
    
    try Arcanus.boot(app)
    
    try app.run()
} catch {
    print(error)
    exit(1)
}
