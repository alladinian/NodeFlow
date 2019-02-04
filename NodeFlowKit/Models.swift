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
        for (index, element) in Element.allCases.enumerated() where self.contains(element) {
            rawValue |= (1 << index)
        }
        return rawValue
    }
}

public enum ContentType: String, Option {
    case color, number, vector, vectorImage, image, string, url, video, calayer, texture, scene, cubeMap
    var associatedColor: NSColor {
        switch self {
        case .vector, .vectorImage: return NSColor.systemPurple
        case .number: return NSColor.systemGray
        default: return NSColor.systemYellow
        }
    }
}

public typealias SupportedTypes = Set<ContentType>

public extension Set where Element == ContentType {
    static var materialContent: SupportedTypes {
        return [.color, .number, .image, .string, .url, .video, .calayer, .texture, .scene, .cubeMap]
    }
}

/*----------------------------------------------------------------------------*/

public protocol NodeProperty: NodeRowRepresentable {
    var name: String { get set }
    var value: Any? { get set }
    var controlView: NSView { get set }
    var topAccessoryView: NSView? { get set }
    var bottomAccessoryView: NSView? { get set }
    var isInput: Bool { get }
    var type: SupportedTypes { get }
    var node: Node! { get set }
}

extension NodeProperty {
    func isCompatibleWith(_ otherProperty: NodeProperty) -> Bool {
        let input  = self.isInput ? self : otherProperty
        let output = !self.isInput ? self : otherProperty
        return input.type.isSuperset(of: output.type)
    }
}

/*----------------------------------------------------------------------------*/

public struct Connection {
    private let id: String
    public weak var inputTerminal: TerminalView!
    public weak var outputTerminal: TerminalView!
    public var input: NodeProperty { return inputTerminal.property }
    public var output: NodeProperty { return outputTerminal.property }

    public init(inputTerminal: TerminalView, outputTerminal: TerminalView) {
        self.id             = NSUUID().uuidString
        self.inputTerminal  = inputTerminal
        self.outputTerminal = outputTerminal
    }
}

/*----------------------------------------------------------------------------*/

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.id == rhs.id
    }
}

/*----------------------------------------------------------------------------*/
public protocol NodeRowRepresentable {}
extension NSView: NodeRowRepresentable {}

open class Node: NSObject {
    let id: String
    public let name: String
    public private(set) var controlRows: [NodeRowRepresentable]
    public private(set) var inputs: [NodeProperty]
    public private(set) var outputs: [NodeProperty]
    public let evaluationFunction: ((Node) -> Void)

    public init(name: String, controlRows: [NodeRowRepresentable], inputs: [NodeProperty], outputs: [NodeProperty], evaluationFunction: @escaping ((Node) -> Void)) {
        self.id                 = NSUUID().uuidString
        self.name               = name
        self.controlRows        = controlRows
        self.inputs             = inputs
        self.outputs            = outputs
        self.evaluationFunction = evaluationFunction
        super.init()
        for (i, _) in self.inputs.enumerated() {
            self.inputs[i].node = self
        }
        for (i, _) in self.outputs.enumerated() {
            self.outputs[i].node = self
        }
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
        nodes.removeAll(where: { $0 == node })
    }

    public func evaluate() {

    }
}
