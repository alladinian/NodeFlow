//
//  Fixtures.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

/// A property that publishes a number (output) and optionally accepts a number (input)
class NumberProperty: NodeProperty {

    init(value: Any? = nil, isInput: Bool = true) {
        super.init()
        self.name    = "Number"
        self.value   = value
        self.isInput = isInput
    }

    var number: Double {
        get { value as? Double ?? 0}
        set { value = newValue }
    }

    var stringValue: String {
        get { NumberFormatter().string(for: value) ?? "0" }
        set { value = Double(newValue) }
    }
}

class MathNode: Node {
    override init() {
        super.init()
        self.name    = "Math"
        self.inputs  = [NumberProperty(value: 0, isInput: true), NumberProperty(value: 0, isInput: true)]
        self.outputs = [NumberProperty(value: 0, isInput: false)]
    }
}

class Board: Graph {
    init(nodes: Set<Node>, connections: Set<Connection>) {
        super.init()
        self.nodes       = nodes
        self.connections = connections
    }
}
