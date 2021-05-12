//
//  ChatClient.swift
//

import Foundation
import Socket
import ChatMessage
import Dispatch
import DatagramReader

enum ChatClientError: Error {
    case wrongAddress
    case networkError(socketError: Error)
    case protocolError
}

class ChatClient {
    let host: String
    let port: Int
    let nick: String
    
    
    init(host: String, port: Int, nick: String) {
        self.host = host
        self.port = port
        self.nick = nick
        
    }
    
    
    func run() throws {
        let timeout = UInt(10 * 1000)
        let bufferSize = 1024
        let count = MemoryLayout<ChatMessage>.size
        var offset = 0
        let Init = ChatMessage.Init
        var welcome = ChatMessage.Welcome
        var accepted: Bool = false
        var buffer = Data(capacity: bufferSize)
        do{
            //Creates address where the server is listening
            guard let serverSocket = Socket.createAddress(for: host, on: Int32(port)) else{
                throw ChatClientError.wrongAddress
                
            }
            //Creates client socket    
            let clientSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)

            //Creates client socket timeout of 10s
            try clientSocket.setReadTimeout(value: timeout)
            
            

            //Encode INIT + nick 
            withUnsafeBytes(of: Init){buffer.append(contentsOf: $0)}
            nick.utf8CString.withUnsafeBytes {buffer.append(contentsOf: $0)}

            //Sends INIT + nick
            try clientSocket.write(from: buffer, to: serverSocket)

            //Sync call read for Welcome
            buffer.removeAll()
            let _ = try clientSocket.readDatagram(into: &buffer)
            
            
           
            //Decoding....
            let _ = withUnsafeMutableBytes(of: &welcome){
                buffer.copyBytes(to: $0, from: offset..<offset+count)
            }
            offset += count
            
            let _ = withUnsafeMutableBytes(of: &accepted){
                buffer.copyBytes(to: $0, from: offset..<offset+count)
            }
          
            offset = 0
            buffer.removeAll()
            guard accepted == true else{
                
                print("IGNORED new user \(nick), nick already used")
                buffer.removeAll()
            
                //Ends chat-client repeated client
                exit(1)
            }
                print("Welcome \(nick)")
                connected(server: serverSocket, client: clientSocket)
            
        }catch let error{
            print("\(error)")
        }
    }

    func connected(server: Socket.Address, client: Socket){
        var recibido: ChatMessage = ChatMessage.Welcome
        let count = MemoryLayout<ChatMessage>.size
        var offset = 0
        //Calls handler to receive messages via it in async queue
        let _ = DatagramReader(socket: client, capacity: 1024){result  in
            switch result{

                case .success(buffer: let buffer, bytesRead: let bytesRead, from: let from):
                    var _ = from
                    var _ = bytesRead
                    let bytesCopied = withUnsafeMutableBytes(of: &recibido){
                        buffer.copyBytes(to: $0, from: offset..<offset+count)
                    }

                    offset += count
                    
                    let inString = buffer.advanced(by: offset).withUnsafeBytes{
                        String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)
                    } 
                        print("\(inString)")
                    
                   
                    assert(bytesCopied == count)
                    offset += count
                    offset = 0

                case .error(DatagramReaderError: let error):
                    switch error{
                        case .timeout:
                            var _ = "CLIENT IGNORES ERRORS"
                            //print("TIMEOUT.....Ignoring error....")

                        case .datagramError(socketError: let error):
                            print("SERVER ERROR -> \(error)")
                            

                    }//switch errors
            }        
        }
        
        //Send function, works on repeat until .quit
        self.send(server: server, client: client)
    }

    func send(server: Socket.Address, client: Socket){
        let quit = ".quit"
        let bufferSize = 1024
        let writer = ChatMessage.Writer
        let logout = ChatMessage.Logout
        var buffer = Data(capacity: bufferSize)
        print("Escribe el mensaje, escribe \(quit) para salir del chat \n")
        repeat{
            do{
                
                while let message = readLine(){
                    guard message != quit else{
                        //Sends Logout and closes
                        withUnsafeBytes(of: logout){buffer.append(contentsOf: $0)}
                        try client.write(from: buffer, to: server)
                        buffer.removeAll()

                        //Ends chat-client
                        exit(1)
                    }

                    //Sends WRITER + message
                    withUnsafeBytes(of: writer){buffer.append(contentsOf: $0)}
                    message.utf8CString.withUnsafeBytes{buffer.append(contentsOf: $0)}
                    try client.write(from: buffer, to: server)
                    buffer.removeAll()
                }
            }catch _ {
                print("error")
            }
        }while true
    } 
}


