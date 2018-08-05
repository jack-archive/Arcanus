// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Arcanus",
    products: [.library(name: "Arcanus", targets: ["Arcanus"]),
               .executable(name: "arcanus", targets: ["CLI"])],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        // .package(url: "https://github.com/vapor/http.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/jmmaloney4/VarInt.git", .branch("master"))

    ],
    targets: [
        .target(name: "Arcanus", dependencies: ["FluentSQLite", "Vapor", "Authentication"]),
        .target(name: "CLI", dependencies: ["Arcanus"]),
        .testTarget(name: "ArcanusTests", dependencies: ["Arcanus"])
    ]
)

