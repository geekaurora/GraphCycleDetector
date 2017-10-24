//
//  GraphCycleDetector.swift
//  Created by Cheng Zhang on 9/5/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/// Dependentable protocol
public protocol Dependentable: Hashable {
    var dependencies: [Self] {get set}
}

/// Generic DAG cycle detector on top of topological sorting with linear time. time = O(n), space = O(n)
/// `Indegree`: the number of nodes depending on the current node
public class GraphCycleDetector<T: Hashable> {
    /// Convenience dependency tuple
    public typealias Dependency = (node: T, prerequisite: T)
    
    // MARK: - Check Cycle

    /// Check whether there's a cycle between dependencies of nodes
    ///
    /// - Parameters:
    ///   - nodes           : Nodes in the graph
    ///   - dependencies    : Dependency edges between nodes
    /// - Returns           : Whether there's a cycle
    public func hasCycle<DependentableNode: Dependentable>(_ nodes: [DependentableNode]) -> Bool{
        return findOrder(nodes) == nil
    }
    
    // MARK: - Find Order
    
    /// Return nodes execution order according to dependencies if no cycle exists, otherwise return nil
    ///
    /// - Parameters:
    ///   - nodes           : Nodes in the graph
    ///   - dependencies    : Dependency edges between nodes
    /// - Returns           : Execution order of nodes
    public func findOrder(_ nodes: [T], dependencies: [Dependency]) -> [T]? {
        guard nodes.count > 0 else { return [] }
        let nodesCount = nodes.count
        var res = [T]()
        
        // 1. Init indegree map: convert graph presentation from edges to indegree of adjacent list
        var indegree = [T: Int]()
        for i in 0 ..< dependencies.count {
            let curNode = dependencies[i].node
            indegree[curNode] = (indegree[curNode] ?? 0) + 1
        }
        
        // 2. Enqueue nodes: indegree == 0
        var queue = [T]()
        for node in nodes where indegree[node] ?? 0 == 0  {
            // Append node with 0 indegree to execution sequence, because all of its dependencies are fulfilled
            res.append(node)
            queue.append(node)
        }
        
        // 3. Dequeue one node and keep enqueuing nodes with 0 indegree
        while !queue.isEmpty {
            // 3-1. Dequeue one
            let prerequisite = queue.removeFirst()
            for i in 0 ..< dependencies.count {
                // Loop through dependencies list: decrement indegree if course's prerequisite == 'prerequisite'
                if dependencies[i].prerequisite == prerequisite {
                    let curNode = dependencies[i].node
                    indegree[curNode] = (indegree[curNode] ?? 0) - 1
                    if indegree[curNode] ?? 0 == 0 {
                        // 3-2. Enqueue node: if indegree == 0
                        queue.append(curNode)
                        // 3-3. Append `curNode` to result
                        res.append(curNode)
                    }
                }
            }
        }
        
        // 4. Verify returned execution path contains all nodes
        return (res.count == nodesCount) ? res : nil
    }
    
    /// Convenience function for `Dependentable` nodes, e.g. `Operation` of `OperationQueue`
    ///
    /// - Parameter nodes: Nodes in the graph
    /// - Returns: Execution order of nodes
    public func findOrder<DependentableNode: Dependentable>(_ nodes: [DependentableNode]) -> [DependentableNode]? {
        // Build dependency edges for input nodes
        let dependencies  = type(of: self).buildDependencies(nodes)
        // Find order according to dependency relationship between nodes
        return findOrder(nodes as! [T], dependencies: dependencies) as? [DependentableNode]
    }
}

fileprivate extension GraphCycleDetector {
    /// Build dependency edges based on input nodes
    ///
    /// - Parameter nodes   : Nodes in the graph
    /// - Returns           : Dependencies between nodes
    static func buildDependencies<DependentableNode: Dependentable>(_ nodes: [DependentableNode]) -> [Dependency] {
        var dependencies = [Dependency]()
        for node in nodes {
            for dependency in node.dependencies {
                let edge = Dependency(node: node as! T, prerequisite: dependency as! T)
                dependencies.append(edge)
            }
        }
        return dependencies
    }
}


