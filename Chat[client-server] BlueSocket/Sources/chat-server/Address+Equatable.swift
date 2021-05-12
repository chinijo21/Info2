//
//  Address+Equatable.swift
//

import Socket

/**
 Allow Addresses to be compared using `==`.
 */
extension Socket.Address: Equatable {
    public static func == (lhs: Socket.Address, rhs: Socket.Address) -> Bool {
        guard let (host_one, port_one) = Socket.hostnameAndPort(from: lhs) else { return false }
        guard let (host_two, port_two) = Socket.hostnameAndPort(from: rhs) else { return false }
        return host_one == host_two && port_one == port_two
    }
}
