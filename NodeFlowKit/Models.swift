//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

public protocol NodeProperty: class {
    var name: String { get set }
    var value: Any? { get set }
    var controlView: NSView { get set }
    var isInput: Bool { get set }
}

/*----------------------------------------------------------------------------*/

public class Connection {
    var input: NodeProperty
    var inputTerminal: TerminalView
    var output: NodeProperty
    var outputTerminal: TerminalView

    init(input: NodeProperty, inputTerminal: TerminalView, output: NodeProperty, outputTerminal: TerminalView) {
        self.input  = input
        self.inputTerminal = inputTerminal
        self.output = output
        self.outputTerminal = outputTerminal
    }
}

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.input === rhs.input && lhs.output === rhs.output
    }
}

/*----------------------------------------------------------------------------*/

open class Node {
    public var name: String
    public var inputs: [NodeProperty]
    public var outputs: [NodeProperty]
    public var evaluationFunction: ((Node) -> Void)

    public init(name: String, inputs: [NodeProperty], outputs: [NodeProperty], evaluationFunction: @escaping ((Node) -> Void)) {
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
