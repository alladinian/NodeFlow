//
//  Fixtures.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

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
    init(value: Any?  = nil) {
        super.init()
        self.name     = "Math"
        self.inputs   = [NumberProperty(), NumberProperty()]
        self.outputs  = [NumberProperty(isInput: false)]
    }
}

class Board: Graph {
    init(nodes: Set<Node>, connections: Set<Connection>) {
        super.init()
        self.nodes       = nodes
        self.connections = connections
    }
}
