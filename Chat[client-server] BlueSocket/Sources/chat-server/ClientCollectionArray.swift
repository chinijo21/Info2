//
//  ClientCollectionArray.swift
//  Implementation of ClientCollection that uses an array as the backend.
//
import Foundation
import Socket

/// Implements a `ClientCollection` using an Array as the backend
struct ClientCollectionArray {
    struct Client {
        //var address: Socket.Address
        var nick: String
        var timestamp: Date
    }

    private var clients = [Client]()
    let uniqueNicks: Bool
    
    

    init(uniqueNicks: Bool = true) {
        self.uniqueNicks = uniqueNicks
    }
}

/// ClientCollection functions have to be implemented here
extension ClientCollectionArray {
    
   
    /**
     Add a new client.
     Throws `ClientCollectionError.repeatedClient` if the nick exists and `uniqueNicks` is true.
     */
    mutating func addClient(nick: String, timestamp: Date) throws {
        if clients.contains(where: {$0.nick == nick}) && uniqueNicks == true {
            throw ClientCollectionError.repeatedClient
        }else {
            clients.append(Client(nick: nick, timestamp: timestamp))
        }
    }
          
    /**
     Remove the client(s) specified by the nick.
     Throws `ClientCollectionError.noSuchClient` if the client does not exist.
     */
    mutating func removeClient(nick: String) throws {
        let index = clients.firstIndex(where: {$0.nick == nick})
        guard index != nil else{
         throw ClientCollectionError.noSuchClient
        } 
        clients.remove(at: index!)
    }

    /**
     Update client timestamp.
     Throws `ClientCollectionError.noSuchClient` if the client does not exist.
    */
    //mutating func updateClient(address: Socket.Address, timestamp: Date) throws {
       //let index = clients.firstIndex(where: {$0.address == address})
       //guard index != nil else{
         //throw ClientCollectionError.noSuchClient
       //} 
       //clients[index!].timestamp = timestamp
    //}

    /**
     Search by address. Returns the client, or `nil` if the address was not found in the list.
     */
    func searchClient(nick: String) -> Client? {
        let index = clients.firstIndex(where: {$0.nick == nick})
        if index == nil{
            return nil
        }else{
            return clients[index!]
        }
        
    }

    func forEach(_ body: (Client) throws -> Void) rethrows {
        for item in clients{
            try body(item)
        }
    }


    
    
}

// Add additional extensions if you need to
//Binary search extension
extension ClientCollectionArray{
    func binarySearch(key: String) -> Bool {
        var highIndex = clients.count - 1
        var lowIndex = 0

        while lowIndex <= highIndex {
            let mid = (lowIndex + highIndex) / 2
            if clients[mid].nick == key {
                //Value found
                return true

            }else if clients[mid].nick < key{
                lowIndex = mid + 1

            }else{
                highIndex = mid - 1
            }
        }
    return false
    }
}