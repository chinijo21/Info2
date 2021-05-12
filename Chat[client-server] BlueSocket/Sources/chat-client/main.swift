import Foundation

// Read command-line argumens
let host = CommandLine.arguments[1]
let port = CommandLine.arguments[2]
let nick = CommandLine.arguments[3]
// Create ChatClient
let client = ChatClient(host: host, port: Int(port)!, nick: nick)
// Run ChatClient
try client.run()
