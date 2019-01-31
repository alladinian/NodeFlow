//
//  SampleNodes.swift
//  NodeFlow
//
//  Created by Vasilis Akoinoglou on 25/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import NodeFlowKit

//public class NumProperty: NSObject, NodeProperty {
//    public var controlView: NSView
//
//    public var isInput: Bool
//
//    public var type: NodePropertyType
//
//    public var node: Node!
//
//    public var name: String = "Number"
//
//    public var value: Any? = nil
//
//    init(name: String) {
//        self.name = name
//    }
//}
//
//public extension Node {
//    public static func mathNode() -> Node {
//        return Node(name: "Sum",
//             inputs: [NumProperty(name: "Number"), NumProperty(name: "Number")],
//             outputs: [NumProperty(name: "Result")],
//             evaluationFunction: { node in
//                guard let a = node.inputs.first?.value as? Int, let b = node.inputs.last?.value as? Int else { return }
//                node.outputs.first?.value = a + b
//        })
//    }
//}
