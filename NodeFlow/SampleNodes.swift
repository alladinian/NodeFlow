//
//  SampleNodes.swift
//  NodeFlow
//
//  Created by Vasilis Akoinoglou on 25/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import NodeFlowKit

struct NumProperty: NodeProperty {
    var topAccessoryView: NSView?
    var bottomAccessoryView: NSView?
    var type: ContentType = .number
    var controlView: NSView
    var isInput: Bool
    weak var node: BaseNode!
    var name: String = "Number"
    var value: Any? = 1

    init(name: String, isInput: Bool) {
        self.name = name
        self.isInput = isInput
        self.controlView = NSSlider(frame: .zero)
    }
}

public extension BaseNode {
    public static func mathNode() -> BaseNode {
        return BaseNode(name: "Sum", controlRows: [],
                    inputs: [NumProperty(name: "Number", isInput: true), NumProperty(name: "Number", isInput: true)],
                    outputs: [NumProperty(name: "Result", isInput: false)])
    }
}
