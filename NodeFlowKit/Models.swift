//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

/*----------------------------------------------------------------------------*/

public protocol Property {
    var name: String { get }
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

/*----------------------------------------------------------------------------*/

public class Node {
    var inputs: [Property]
    var outputs: [Property]
    var evaluationFunction: ((Property) -> Void)

    init(inputs: [Property], outputs: [Property], evaluationFunction: @escaping ((Property) -> Void)) {
        self.inputs             = inputs
        self.outputs            = outputs
        self.evaluationFunction = evaluationFunction
    }
}

/*----------------------------------------------------------------------------*/

public class Graph {
    var nodes: [Node]
    var connections: [Connection]

    init(nodes: [Node], connections: [Connection]) {
        self.nodes       = nodes
        self.connections =  connections
    }

    func evaluate() {

    }
}
