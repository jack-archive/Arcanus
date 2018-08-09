import Arcanus
import CommandLineKit
import Foundation
import Service
import Vapor

do {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()

    try Arcanus.configure(&config, &env, &services)

    let app = try Application(config: config,
                              environment: env,
                              services: services)

    try Arcanus.boot(app)

    try app.run()
} catch {
    print(error)
    exit(1)
}
