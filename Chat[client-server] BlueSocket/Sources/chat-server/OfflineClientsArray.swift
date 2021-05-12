import Socket
import Foundation

struct OfflineClientCollection {
    struct Client {
        
        var nick: String
        var timestamp: Date
        var reason: String
    }

    private var offClients = [Client]()
    let uniqueNicks: Bool
    
    

    init(uniqueNicks: Bool = true) {
        self.uniqueNicks = uniqueNicks
    }
}

extension OfflineClientCollection{
    mutating func addClient(nick: String, timestamp: Date, reason: String){
        if binarySearch(key: nick) == true && uniqueNicks == true {
            //Already removed
        }else{
            offClients.append(Client(nick: nick, timestamp: timestamp, reason: reason))
            sorting()
        }
    }
    
    //Sorting the array alphabetically
    mutating func sorting(){
        offClients = offClients.sorted{$0.nick.lowercased() < $1.nick.lowercased()}
    }

    mutating func binarySearch(key: String) -> Bool {
        var highIndex = offClients.count - 1
        var lowIndex = 0

        while lowIndex <= highIndex {
            let mid = (lowIndex + highIndex) / 2
            if offClients[mid].nick == key {
                //Value found, delete the client
                offClients.remove(at: mid)
                return true
            }else if offClients[mid].nick < key{
                lowIndex = mid + 1

            }else{
                highIndex = mid - 1
            }
        }

        return false
    }

    func forEach(_ body: (Client) throws -> Void) rethrows {
        for item in offClients{
            try body(item)
        }
    }
}