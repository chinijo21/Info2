import Foundation
import Socket
import ChatMessage

public enum DatagramReaderError : Error {
    case timeout
    case datagramError(socketError: Error)
}

public enum DatagramReaderResult {
    case success(buffer: Data, bytesRead: Int, from: Socket.Address?)
    case error(DatagramReaderError)
}

/// Simple helper class to read forever from a socket using a background queue.
public class DatagramReader {
    func readDatagram(from socket: Socket, into buffer: inout Data) throws -> (bytesRead: Int, address: Socket.Address?) {
        let (bytesRead, address) = try socket.readDatagram(into: &buffer)
        if bytesRead == 0 && errno == EAGAIN {
            throw DatagramReaderError.timeout
        }
        return (bytesRead, address)
    }

    /** Creates a DatagramReader and read datagrams forever in a loop. */
    public init(socket: Socket, capacity: Int, handler: @escaping (DatagramReaderResult) -> Void) {
        var buffer = Data(capacity: capacity)
 
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            repeat {
                buffer.removeAll()
                do {
                    let (bytesRead, address) = try self.readDatagram(from: socket, into: &buffer)
                    // TODO: main queue, buffer copy

                    handler(.success(buffer: buffer, bytesRead: bytesRead, from: address))
                } catch DatagramReaderError.timeout {
                    handler(.error(.timeout))
                } catch {
                    handler(.error(.datagramError(socketError: error)))
                }
            } while true
        }
    }
    
    /** Use this version to ignore all errors and just receive the buffer on success. */
    //public convenience init(socket: Socket, capacity: Int, handler: @escaping (Data) -> Void) {
        //self.init(socket: socket, capacity: capacity) { (result: DatagramReaderResult) in
            //if case .success(let buffer, _, _) = result {
                //handler(buffer)
            //}
        //}
    //}
}
