// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chat client-server Swift&BlueSocket",
    dependencies: [
        .package(name: "Socket", url: "https://github.com/Kitura/BlueSocket.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatMessage",
            dependencies: ["Socket"]),

        .target(
            name: "DatagramReader",
            dependencies: ["Socket"]),
       
        .target(
            name: "chat-server",
            dependencies: ["Socket", "ChatMessage", "DatagramReader"]),
            
        .target(
            name: "chat-client",
            dependencies: ["Socket", "ChatMessage", "DatagramReader"]),

      
    ]
)
