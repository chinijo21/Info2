//
//  SymbolTable.swift
//  
//
//  Created by Pedro Cuenca on 2/1/21.
//
import Foundation

class BinaryTreeNode<K, V> {
    var key: K
    var value: V
    
    var left: BinaryTreeNode<K, V>? = nil
    var right: BinaryTreeNode<K, V>? = nil
    //var min: BinaryTreeNode<K, V> {
        //return left?.min ?? self
    //}
        
    init(key: K, value: V) {
        self.key = key
        self.value = value
    }
}

public enum SymbolTableError : Error {
    case maxCapacityReached
}

public protocol SymbolTable{
    associatedtype Key: Equatable
    associatedtype Value
    
    var count: Int { get }
    var maxCapacity: Int { get }
    
    func get(key: Key) -> Value?
    mutating func put(key: Key, value: Value) throws
    mutating func remove(key: Key) -> Value?
    
    func forEach(_ body: (Key, Value) throws -> Void) rethrows
}

struct BinaryTreeMap<K : Comparable, V> : SymbolTable{
    
    
    var maxCapacity: Int = 50

    var root: BinaryTreeNode<K, V>?
    
    typealias TreeNode = BinaryTreeNode<K, V>

    var count: Int = 0

    public init() {}

    public func get(key: K) -> V? {
        return get(node: root, key: key)
    }

    private func get(node: TreeNode?, key: K) -> V? {
        guard let node = node else { return nil }
        if key == node.key { return node.value }
        if key < node.key { return get(node: node.left, key: key) }
        return get(node: node.right, key: key)
    }

    //Puts a new key, value in the tree
    public mutating func put(key: K, value: V) throws {
        if count == maxCapacity {
            throw SymbolTableError.maxCapacityReached
        }else{
            put(node: &root, key: key, value: value)
            count = count + 1                           //Updates count
        }
        
    }

    private func put(node: inout TreeNode?, key: K, value: V) {
        guard let theNode = node else {
            node = BinaryTreeNode(key: key, value: value)
            return
        }
        
        if key == theNode.key { theNode.value = value }
        if key <  theNode.key { put(node: &theNode.left, key: key, value: value) }
        if key >  theNode.key { put(node: &theNode.right, key: key, value: value) }
    }

    //Update the value of the key
    public mutating func updateValue(key: K, newValue: V) {
        
        update(node: &root, key: key, newValue: newValue)
    }

    private func update(node: inout TreeNode?, key: K, newValue: V){
        guard let theNode = node else{
            node = BinaryTreeNode(key: key, value: newValue)
            return
        }

        if key == theNode.key {theNode.value = newValue}
        if key < theNode.key {update(node: &theNode.left, key: key, newValue: newValue)}
        if key >  theNode.key { update(node: &theNode.right, key: key, newValue: newValue) }
    }

    public mutating func remove(key: K) -> V? {
        let node = remove(node: &root, key: key)
        count = count - 1                           //Update count
        return node
    }




    public func forEach(_ body: (K, V) throws -> Void) rethrows {

    }



    public func traverse(_ proccess: (K, V) throws -> Void) rethrows {
        // Invokes the recursive function from the root node
        try traverse(node: root, proccess)
    }
    
    private func traverse(node: TreeNode?, _ proccess: (K, V) throws -> Void) rethrows {
        guard let node = node else { return }
        try traverse(node: node.left, proccess)
        try proccess(node.key, node.value)
        try traverse(node: node.right, proccess)
    }

}
//Everything about removing 
extension BinaryTreeMap{

    private func min(node: TreeNode) -> TreeNode {
	    guard let leftNode = node.left else {
		    return node
	    }
	    return min(node: leftNode)
    }

    private func deleteMin(node: TreeNode) -> TreeNode? {
	    guard let leftNode = node.left else {
		    return node.right
	    }
	
	    node.left = deleteMin(node: leftNode)
	
	    return node
    }
    private func remove(node: inout TreeNode?, key: K)-> V? {
        guard var theNode = node else {
            return nil
        }

        if key <  theNode.key { return remove(node: &theNode.left, key: key) }
        if key >  theNode.key { return remove(node: &theNode.right, key: key) }

        let result = theNode.value

        
        // 1 the node is a leaf node, you simply return nil, thereby removing the current node
        if theNode.left == nil && theNode.right == nil {node = nil}

        // 2 node has no left child, you return node @ right to reconnect the right subtree
        if theNode.left == nil {return remove(node: &theNode.right, key: key)}

        // 3 the node has no right child, you return the node @ left to reconnect the left subtree
        if theNode.right == nil {return remove(node: &theNode.left, key: key)}

        // 4 the node to be removed has both a left and
        // right child. Replace the node’s value with the smallest value
        // from the right subtree. Then call remove on the right child to
        // remove this swapped value.
        if theNode.right != nil && theNode.left != nil{
            theNode = min(node: (node?.right)!)
            theNode.right = deleteMin(node: (node?.right)!)
            theNode.left = node?.left
            return remove(node: &theNode.right, key: theNode.key)
        }
        
        return result
    }


}

//Extra...
extension BinaryTreeMap{
    //Depth of the tree
    public func depth() -> Int {
        return depth(root)
    }
    
    private func depth(_ node: TreeNode?) -> Int {
        if node == nil{
            return 0
        }else{
            let profIzq = depth(node?.left)
            let profDer = depth(node?.right)
            
            if profIzq > profDer{
                return profIzq + 1
            }else{
                return profDer + 1
            }
        }
    }

    //Different traversal algorithms
    public func traversePre(_ proccess: (K, V) throws -> Void) rethrows{
        try traversePre(node: root, proccess)
    }

    public func traversePost(_ proccess: (K, V) throws -> Void) rethrows{
        try traversePost(node: root, proccess)
    }

    private func traversePre(node: TreeNode?, _ proccess: (K, V) throws -> Void) rethrows {
        guard let node = node else { return }

        try proccess(node.key, node.value)
        try traverse(node: node.left, proccess)
        try traverse(node: node.right, proccess)
    }

    private func traversePost(node: TreeNode?, _ proccess: (K, V) throws -> Void) rethrows {
        guard let node = node else { return }
        
        try traverse(node: node.left, proccess)
        try traverse(node: node.right, proccess)
        try proccess(node.key, node.value)
    }

    //Average reads for key
    public func readsForKey(key: K) -> Int? {
        return readsForKey(node: root, key: key)
    }
    
    private func readsForKey(node: TreeNode?, key: K) -> Int? {
        let keyTo = key
        var keyReads = 0
        var keyValue = 0
        traverse{key, value in
            if key != keyTo{
                keyReads = keyReads + 1
            }else if key == keyTo{
                keyValue = keyReads
            }
                 
        }
        return keyValue
    }

    public func averageReadsPerKey() -> Double {
        let nodes = count
        var readCount: Int = 0

        traverse{key, value in
            let forKey = readsForKey(key: key) ?? 0
            readCount = readCount + forKey
        }
        let total = Double(readCount/nodes)
        return total

    }

}