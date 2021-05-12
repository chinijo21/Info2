//
//  ChatServer.swift
//  Juan Antonio Cejudo Ventura (ja.cejudo.2016@alumnos.urjc.es)
//
import Foundation
import Socket
import ChatMessage
import Dispatch
import DatagramReader

enum ChatServerError: Error {
    /**
     Thrown on communications error.
     Initialize with the underlying Error thrown by the Socket library.
     */
    case networkError(socketError: Error)
    
    /**
     Thrown if an unexpected message or argument is received.
     For example, the server should never receive a 'Server' message.
     */
    case protocolError

    case serverError
}



class ChatServer {
    static let quit = ".quit"
    let bufferSize = 1024
    let port: Int
    let maxClient: Int 
    var serverSocket: Socket
    var serverError: ChatServerError? = nil
    
    
    var clientsOff = OfflineClientCollection(uniqueNicks: true)
    var arbol = BinaryTreeMap<String, (Socket.Address, Date)>()
    
    
    
    init(port: Int, maxClient: Int) throws {
        self.port = port
        self.maxClient = maxClient
        serverSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
    }

    func run() throws {
        //Max capacity for the tree
        self.arbol.maxCapacity = self.maxClient
        
        try readAndProcessMessages()
        keyboardLoop()
        
        //serverError check
        repeat{
            sleep(1)
        }while serverError == nil

       throw serverError!
    }

    func readAndProcessMessages() throws{
        //var buffer = Data(capacity: self.bufferSize)
        var recibido: ChatMessage = ChatMessage.Welcome
        let count = MemoryLayout<ChatMessage>.size
        var offset = 0
        var out: String = ""
        
        try self.serverSocket.listen(on: self.port)
        print("Listening on \(self.port)") 

        //Async queue and switch call to fucntions
        var _ = DatagramReader(socket: self.serverSocket, capacity: self.bufferSize){result  in
            switch result{

                case .success(buffer: let buffer, bytesRead: let bytesRead, from: let from):
                    var _ = bytesRead
                    let bytesCopied = withUnsafeMutableBytes(of: &recibido){
                        buffer.copyBytes(to: $0, from: offset..<offset+count)
                    }

                    offset += count
                    if recibido == ChatMessage.Init || recibido == ChatMessage.Writer{
                        let inString = buffer.advanced(by: offset).withUnsafeBytes{
                            String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)
                        } 
                        out = inString
                    }else{

                    }
                   
                    assert(bytesCopied == count)
                    offset += count
                    offset = 0

                    switch recibido{

                        case .Init: 
                            let nick = out
                            self.newConnection(address: from!, nick: nick)
                            offset = 0

                        case .Logout: 
                            self.leaves(address: from!) 
                            offset = 0

                        case .Server: var _ = "NADA"

                        case .Welcome: var  _ = "NADA"

                        case .Writer: 
                            let msg = out
                            self.write(address: from!, msg: msg)
                            offset = 0
                    }///switch  recibido

                case .error(DatagramReaderError: let error):
                    switch error{

                        case .timeout:
                            print("TIMEOUT.....Ignoring error....")

                        case .datagramError(socketError: let error):
                            print("ERROR -> \(error)")
                            self.serverError = .networkError(socketError: error)

                    }//switch errors
            }//switch result
        }
    }

    func keyboardLoop(){
        let queue = DispatchQueue.global()
        
        print("To check connected clients type -l/-L /n To check offline clients type -o/-O")

        //Queue to print connected client's list or offline clients list
        queue.async{
                repeat{
                    //Formating Date to "yy-MMM-dd HH:mm"

                    let lista = readLine()
                    if lista == "-l" || lista == "-L" {
                        print(" ACTIVE CLIENTS \n ==================================================================")
                        self.arbol.traverse{key, value in
                            
                            let df = DateFormatter()
                            df.dateFormat = "yy-MMM-dd HH:mm"
                            let fecha = df.string(from: value.1)

                            //Formating to IP:Port
                            let (clientHostname, clientPort) = Socket.hostnameAndPort(from: value.0)!
                            
                            //Prints list
                            print("\(key) at (\(clientHostname)):\(clientPort) -->  \(fecha) \n")

                        }
                        print("Online clients -> \(self.arbol.count) of \(self.arbol.maxCapacity)")
                    }else if lista == "-o" || lista == "-O"{
                        //Formating Date to "yy-MMM-dd HH:mm"
                        print(" OFFLINE CLIENTS \n ==================================================================")
                        self.clientsOff.forEach{client in
                            let df = DateFormatter()
                            df.dateFormat = "yy-MMM-dd HH:mm"
                            let fecha = df.string(from: client.timestamp)
                            
                            //Prints list
                            print("\(client.nick) last seen \(fecha) --> why?: \(client.reason) \n")
                        }
                    }else{

                    }
                }while true
        }

    }

    func newConnection(address: Socket.Address, nick: String){
        
        do{
            let welcome = ChatMessage.Welcome
            var buffer = Data(capacity: self.bufferSize)
            
            //Checks if the nick exists in tree
            if arbol.get(key: nick) != nil{
                //Client rejected
                buffer.removeAll()
                let notAccepted = false
                print("\(ChatMessage.Init) received from \(nick): IGNORED. Nick Already used \n")
                
                //Sends Welcome(Rejected) message to client
                withUnsafeBytes(of: welcome){buffer.append(contentsOf: $0)}
                withUnsafeBytes(of: notAccepted){buffer.append(contentsOf: $0)}
                
                try self.serverSocket.write(from: buffer, to: address)
                buffer.removeAll()

            //Check if exists in off array and removes it of it if true
            }else if clientsOff.binarySearch(key: nick) == true{
                toTree(address: address, nick: nick, returning: true)
            }else if clientsOff.binarySearch(key: nick) == false{
                toTree(address: address, nick: nick, returning: false)
            }

            buffer.removeAll()
        }catch let error{
            print("error \(error)")
        }
    }

    func toTree(address: Socket.Address, nick: String, returning: Bool){
        let welcome = ChatMessage.Welcome
        let server = ChatMessage.Server
        var buffer = Data(capacity: self.bufferSize)
        let timestamp = Date()
        let serverName = "server"
        let joins: String 
        let accepted = true
        let reason = "idle"

        do{
            //Client accepted
            try arbol.put(key: nick, value: (address, timestamp))
            print("\(ChatMessage.Init) received from \(nick): ACCEPTED \n")
                
             //Sends Welcome(Accepted) message to client
            withUnsafeBytes(of: welcome){buffer.append(contentsOf: $0)}
            withUnsafeBytes(of: accepted) { buffer.append(contentsOf: $0) }
                
            //Sends msg to the client
            try self.serverSocket.write(from: buffer, to: address)

            buffer.removeAll()
            if returning == true{
                joins = "\(nick) rejoins the chat"
            }else{
                joins = "\(nick) joins the chat"
            }

            let newCon = "\(serverName) >> \(joins)"  
            //Sends server message to the rest of users SERVER <nick> joins the chat
            withUnsafeBytes(of: server){buffer.append(contentsOf: $0)}
            newCon.utf8CString.withUnsafeBytes{buffer.append(contentsOf: $0)}
            self.broadcast(address: address, buffer: buffer)

        }catch SymbolTableError.maxCapacityReached{
            print("Max capacity reached, deleting client with oldest timestamp")
            var clientCount: Int = 0
            var oldClient = ""
            var oldDate = timestamp
            arbol.traverse{key, value in
                clientCount = clientCount + 1
                if value.1 < oldDate{
                    oldDate = value.1
                    oldClient = key
                }

                if clientCount == arbol.count{
                    //Remove the client with oldest timestamp

                    //Sends kicked client to the rest, included the one that we kicked 
                    let idle = "\(oldClient) banned for being idle too long"

                    //Server log
                    print("\(idle)")


                    withUnsafeBytes(of: server){buffer.append(contentsOf: $0)}
                    idle.utf8CString.withUnsafeBytes{buffer.append(contentsOf: $0)}
                    self.broadcast(address: address, buffer: buffer)

                    //Removing client from tree
                    let removed = arbol.get(key: oldClient)
                    let _ = arbol.remove(key: oldClient)

                    //Adding to offline array
                    clientsOff.addClient(nick: oldClient, timestamp: removed!.1, reason:reason)
                }else{

                }
            }

            //TODO: Tries again... need to figure out how to implement remove root...
            toTree(address: address, nick: nick, returning: returning)

        }catch let error{
            print("\(error)")
        }
    }

    func write(address: Socket.Address, msg: String){
        let server = ChatMessage.Server
        var buffer = Data(capacity: self.bufferSize)
        let timestamp = Date()
        
        arbol.traverse{key, value in
            if address == value.0{
                let send = "\(key) >> \(msg)"
  
                //Update the client timestamp
                arbol.updateValue(key: key, newValue: (address, timestamp))

                //Server log
                print("\(ChatMessage.Writer) received from \(key): \(msg) \n ")

                buffer.removeAll()

                //CODE message to the rest SERVER + nick: <msg>
                withUnsafeBytes(of: server){buffer.append(contentsOf: $0)}
                send.utf8CString.withUnsafeBytes {buffer.append(contentsOf: $0)}
            
                //BROADCAST
                self.broadcast(address: address, buffer: buffer)
                
                //Clean buffer
                buffer.removeAll()

            }else {
                //print("DIRECCION DE CLIENTE INCORRECTA")    
            }
        }

        buffer.removeAll()
    }

    func leaves(address: Socket.Address){
        var buffer = Data(capacity: self.bufferSize)
        let server = ChatMessage.Server
        let servidor = "server"
        let reason = "logout"
            
        //Check if exists
        arbol.traverse{key, value in
            if address == value.0{
                let leaves = "\(key) leaves the chat"
                let msg = "\(servidor) >> \(leaves)"
                let offClient = arbol.get(key: key)
                let _ = arbol.remove(key: key)
                
                //Server log
                print("\(ChatMessage.Logout) received from \(key)\n ")

                //Put it in offline clients array (nick + last known date + reason?[LOGOUT])
                clientsOff.addClient(nick: key, timestamp: offClient!.1, reason: reason)
 
                buffer.removeAll()

                //SERVER + server: <nick> se desconecto
                withUnsafeBytes(of: server){buffer.append(contentsOf: $0)}
                msg.utf8CString.withUnsafeBytes {buffer.append(contentsOf: $0)}
            
                //Broadcast
                self.broadcast(address: address, buffer: buffer)

                //Clean Buffer
                buffer.removeAll()
            }
        }
    }

    func broadcast(address: Socket.Address, buffer: Data){
        do{
            try arbol.traverse {key, value in
                if address != value.0 { 
                   try self.serverSocket.write(from: buffer, to: value.0) 
                   
                } 
            }
        }catch let error{
            print("\(error)")
        }
    }
}

