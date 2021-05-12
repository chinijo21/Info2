//
//  ClientCollection.swift
//

import Foundation
import Socket

public enum ClientCollectionError: Error {
    /** Thrown by addClient, if attempting to add the same nick and `uniqueNames` is `true` */
    case repeatedClient
    
    /** Thrown by removeClient and updateClient, if the client does not exist */
    case noSuchClient
}

public struct Client {
    var address: Socket.Address
    var nick: String
    var timestamp: Date
}

public protocol ClientCollection {
    /** Indicates whether nicknames need to be unique or can be repeated. */
    var uniqueNicks: Bool { get }
    
    /**
     Add a new client.
     Throws `ClientCollectionError.repeatedClient` if the nick exists and `uniqueNicks` is true.
     */
    mutating func addClient(address: Socket.Address, nick: String, timestamp: Date) throws
    
    /**
     Remove the client(s) specified by the nick.
     Throws `ClientCollectionError.noSuchClient` if the client does not exist.
     */
    mutating func removeClient(nick: String) throws
    
    /**
     Update client timestamp.
     Throws `ClientCollectionError.noSuchClient` if the client does not exist.
     */
    mutating func updateClient(address: Socket.Address, timestamp: Date) throws
    
    /**
     Search by address. Returns the client, or `nil` if the address was not found in the list.
     */
    func searchClient(address: Socket.Address) -> Client?
    
    /**
     Runs `body` closure for each element in the list.
     `rethrows` means that `forEach` will throw if the closure `throws`.
     */
    func forEach(_ body: (Client) throws -> Void) rethrows
}
