//
//  Fixtures.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

struct NumberProperty: NodeProperty, Identifiable {
    var id: String        = NSUUID().uuidString
    var name: String      = "Number"
    var value: Any?       = 0
    var isInput: Bool     = true
    var type: ContentType = .number
    var number: Double {
        get { value as? Double ?? 0}
        set { value = newValue }
    }
    var stringValue: String {
        get { NumberFormatter().string(for: value) ?? "0" }
        set { value = Double(newValue) }
    }
}

struct MathNode: Node, Identifiable {
    var id: String              = NSUUID().uuidString
    var name: String            = "Math"
    var inputs: [NodeProperty]  = [NumberProperty(), NumberProperty()]
    var outputs: [NodeProperty] = [NumberProperty(isInput: false)]
    var position: CGPoint       = .zero
}

struct Board: Graph {
    var nodes: [Node]
    var connections: [Connection]
    func addConnection(_ connection: Connection) {}
    func removeConnection(_ connection: Connection) {}
    func addNode(_ node: Node) {}
    func removeNode(_ node: Node) {}
    func shouldAddConnection(_ connection: Connection) -> Bool {
        return true
    }
}
