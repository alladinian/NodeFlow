//
//  ViewController.swift
//  NodeFlow
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa
import NodeFlowKit
import SceneKit
import SceneKit.ModelIO



class ViewController: BoardViewController {

    var graph: MDLMaterialPropertyGraph!

    override func viewDidLoad() {
        super.viewDidLoad()

//        let my
//        let myNode = MDLMaterialPropertyNode(inputs: <#T##[MDLMaterialProperty]#>, outputs: <#T##[MDLMaterialProperty]#>, evaluationFunction: <#T##(MDLMaterialPropertyNode) -> Void#>)

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func didConnect(output: Property, toInput input: Property) {
        let connection = MDLMaterialPropertyConnection(output: output as! MDLMaterialProperty, input: input as! MDLMaterialProperty)
        graph.connections.append(connection)
        graph.setcon
    }


}


extension MDLMaterialProperty: Property {
    public var value: Any? {
        get {
            switch type {
            case .none: return nil
            case .string: return stringValue
            case .URL: return urlValue
            case .texture: return textureSamplerValue
            case .color: return color
            case .float: return floatValue
            case .float2: return float2Value
            case .float3: return float3Value
            case .float4: return float4Value
            case .matrix44: return matrix4x4
            }
        }
        set {
            switch type {
            case .none: break
            case .string: stringValue = newValue as? String
            case .URL: urlValue = newValue as? URL
            case .texture: textureSamplerValue = newValue as? MDLTextureSampler
            case .color: color = (newValue as! CGColor)
            case .float: floatValue = newValue as? Float ?? 0
            case .float2: float2Value = newValue as? vector_float2 ?? vector_float2([])
            case .float3: float3Value = newValue as? vector_float3 ?? vector_float3([])
            case .float4: float4Value = newValue as? vector_float4 ?? vector_float4([])
            case .matrix44: matrix4x4 = newValue as? matrix_float4x4 ?? matrix_float4x4(rows: [])
            }
        }
    }
}
