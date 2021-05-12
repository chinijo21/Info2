import Foundation
func setClients() -> String?{
    print("Please set a client max between 2 and 50")
    let inString = readLine()
    
    if Int(inString!)! > 50 || Int(inString!)! < 2 {
        let _ = setClients()
    }

    return inString
}

// Read command-line arguments
let port = CommandLine.arguments[1]
var num = CommandLine.arguments[2]
let max: String
// Create ChatServer
if Int(num)! > 50 || Int(num)! < 2{
    num = setClients()!
    max = num
}else{
    max = num
}

let server =  try ChatServer(port: Int(port)!, maxClient: Int(max)!)

do{
    // Run ChatServer
    try server.run() 
}catch ChatServerError.serverError{
    exit(1)
}






  
    
    

    

