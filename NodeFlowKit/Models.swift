//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

public protocol Property: class {
    var name: String { get set }
    var value: Any? { get set }
}

/*----------------------------------------------------------------------------*/

public class Connection {
    var input: Property?
    var output: Property?

    init(input: Property, output: Property) {
        self.input  = input
        self.output = output
    }
}

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.input === rhs.input && lhs.output === rhs.output
    }
}

/*----------------------------------------------------------------------------*/

public class Node {
    public var name: String
    public var inputs: [Property]
    public var outputs: [Property]
    public var evaluationFunction: ((Node) -> Void)

    public init(name: String, inputs: [Property], outputs: [Property], evaluationFunction: @escaping ((Node) -> Void)) {
        self.name               = name
        self.inputs             = inputs
        self.outputs            = outputs
        self.evaluationFunction = evaluationFunction
    }
}

/*----------------------------------------------------------------------------*/

public class Graph {
    public var nodes: [Node]
    public var connections: [Connection]

    public init(nodes: [Node], connections: [Connection] = []) {
        self.nodes       = nodes
        self.connections = connections
    }

    public func addConnection(_ connection: Connection) {
        guard !connections.contains(connection) else { return }
        connections.append(connection)
    }

    public func removeConnection(_ connection: Connection) {
        connections.removeAll(where: { $0 === connection })
    }

    public func evaluate() {

    }
}
