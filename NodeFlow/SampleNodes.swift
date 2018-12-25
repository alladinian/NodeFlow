//
//  SampleNodes.swift
//  NodeFlow
//
//  Created by Vasilis Akoinoglou on 25/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import NodeFlowKit

class NumProperty: Property {
    var name: String = "Number"
    var value: Any? = nil
    init(name: String) {
        self.name = name
    }
}

extension Node {
    static func mathNode() -> Node {
        return Node(name: "Sum",
             inputs: [NumProperty(name: "Number"), NumProperty(name: "Number")],
             outputs: [NumProperty(name: "Result")],
             evaluationFunction: { node in
                guard let a = node.inputs.first?.value as? Int, let b = node.inputs.last?.value as? Int else { return }
                node.outputs.first?.value = a + b
        })
    }
}
