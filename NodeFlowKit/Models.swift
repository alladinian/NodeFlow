//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

/*
 You can set a value for this property using any of the following types:

 - A color (NSColor/UIColor or CGColor), specifying a uniform color for the material’s surface
 - A number (NSNumber), specifying a uniform scalar value for the material's surface (useful for physically based properties such as metalness)
 - An image (NSImage/UIImage or CGImage), specifying a texture to be mapped across the material’s surface
 - An NSString or NSURL object specifying the location of an image file
 - A video player (AVPlayer) or live video capture preview (AVCaptureDevice, in iOS only)
 - A Core Animation layer (CALayer)
 - A texture (SKTexture, MDLTexture, MTLTexture, or GLKTextureInfo)
 - A SpriteKit scene (SKScene)
 - A specially formatted image or array of six images, specifying the faces of a cube map
*/

// https://nshipster.com/optionset/
protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }
        return rawValue
    }
}

enum ContentType: String, Option {
    case color, number, image, string, url, video, calayer, texture, scene, cubeMap
}

typealias SupportedTypes = Set<ContentType>

public enum NodePropertyType: String, Option {
    case color
    case number
    case image
    case normal
    case multi

    var color: NSColor {
        switch self {
        case .color: return NSColor.systemYellow
        case .number: return NSColor.systemBlue
        case .image: return NSColor.systemRed
        case .normal: return NSColor.systemPink
        case .multi: return NSColor.systemGreen
        }
    }

    var supportedTypes: SupportedTypes {
        switch self {
        case .color: return [.color]
        case .number: return [.number]
        case .image: return [.image]
        case .normal: return [.image]
        case .multi: return Set(ContentType.allCases)
        }
    }
}


public protocol NodeProperty: NSObjectProtocol {
    var name: String { get set }
    var value: Any? { get set }
    var controlView: NSView { get set }
    var isInput: Bool { get }
    var type: NodePropertyType { get }
    var node: Node! { get set }
}

/*----------------------------------------------------------------------------*/

public class Connection {
    private let id: String
    public var input: NodeProperty { return inputTerminal.property }
    public var inputTerminal: TerminalView
    public var output: NodeProperty { return outputTerminal.property }
    public var outputTerminal: TerminalView

    public init(inputTerminal: TerminalView, outputTerminal: TerminalView) {
        self.id             = NSUUID().uuidString
        self.inputTerminal  = inputTerminal
        self.outputTerminal = outputTerminal
    }

    public static func isProperty(_ property: NodeProperty, compatibleWith otherProperty: NodeProperty) -> Bool {
        let input = property.isInput ? property : otherProperty
        let output = !property.isInput ? property : otherProperty
        return input.type.supportedTypes.isSuperset(of: output.type.supportedTypes)
    }
}

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.id == rhs.id
    }
}

/*----------------------------------------------------------------------------*/

open class Node: NSObject {
    private let id: String
    public var name: String
    public var inputs: [NodeProperty]
    public var outputs: [NodeProperty]
    public var evaluationFunction: ((Node) -> Void)

    public init(name: String, inputs: [NodeProperty], outputs: [NodeProperty], evaluationFunction: @escaping ((Node) -> Void)) {
        self.id                 = NSUUID().uuidString
        self.name               = name
        self.inputs             = inputs
        self.outputs            = outputs
        self.evaluationFunction = evaluationFunction
    }
}

/*----------------------------------------------------------------------------*/

public class Graph {
    public fileprivate(set) var nodes: [Node]
    public fileprivate(set) var connections: [Connection]

    public init(nodes: [Node], connections: [Connection] = []) {
        self.nodes       = nodes
        self.connections = connections
    }

    public func addConnection(_ connection: Connection) {
        guard !connections.contains(connection) else { return }
        connections.append(connection)
    }

    public func removeConnection(_ connection: Connection) {
        connections.removeAll(where: { $0 == connection })
    }

    public func addNode(_ node: Node) {
        nodes.append(node)
    }

    public func removeNode(_ node: Node) {
        guard !nodes.contains(node) else { return }
        nodes.removeAll(where: { $0 == node })
    }

    public func evaluate() {

    }
}
