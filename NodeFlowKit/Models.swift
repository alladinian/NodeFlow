//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import Cocoa

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


public struct ContentType: OptionSet {
    public let rawValue: Int

    public static let color       = ContentType(rawValue: 1<<0)
    public static let number      = ContentType(rawValue: 1<<1)
    public static let vector      = ContentType(rawValue: 1<<2)
    public static let vectorImage = ContentType(rawValue: 1<<3)
    public static let image       = ContentType(rawValue: 1<<4)
    public static let string      = ContentType(rawValue: 1<<5)
    public static let url         = ContentType(rawValue: 1<<6)
    public static let video       = ContentType(rawValue: 1<<7)
    public static let calayer     = ContentType(rawValue: 1<<8)
    public static let texture     = ContentType(rawValue: 1<<9)
    public static let scene       = ContentType(rawValue: 1<<10)
    public static let cubeMap     = ContentType(rawValue: 1<<11)

    public static var materialContent: ContentType {
        return [.color, .number, .image, .string, .url, .video, .calayer, .texture, .scene, .cubeMap]
    }

    public var associatedColors: [NSColor] {
        return elements().map { element in
            switch element {
            case .vector, .vectorImage: return NSColor.systemPurple
            case .number: return NSColor.systemGray
            default: return NSColor.systemYellow
            }
        }
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/*----------------------------------------------------------------------------*/
public protocol NodeRowRepresentable {}
extension NSView: NodeRowRepresentable {}

public protocol NodeProperty: NodeRowRepresentable {
    var name: String { get set }
    var value: Any? { get set }
    var controlView: NSView { get set }
    var topAccessoryView: NSView? { get set }
    var bottomAccessoryView: NSView? { get set }
    var isInput: Bool { get }
    var type: ContentType { get }
    var node: Node! { get set }
}

func asIO(_ a: NodeProperty, _ b: NodeProperty) -> (input: NodeProperty, output: NodeProperty) {
    return ((a.isInput ? a : b), (!a.isInput ? a : b))
}

extension NodeProperty {
    func isCompatibleWith(_ otherProperty: NodeProperty) -> Bool {
        let (input, output) = asIO(self, otherProperty)
        return input.type.isSuperset(of: output.type)
    }
}

/*----------------------------------------------------------------------------*/
public protocol ConnectionRepresenter: Equatable {
    var inputTerminal: TerminalView! { get }
    var outputTerminal: TerminalView! { get }
    var input: NodeProperty { get }
    var output: NodeProperty { get }
    var link: LinkLayer { get }
}

public struct Connection: ConnectionRepresenter {
    private let id: String
    public weak var inputTerminal: TerminalView!
    public weak var outputTerminal: TerminalView!
    public var input: NodeProperty { return inputTerminal.property }
    public var output: NodeProperty { return outputTerminal.property }
    public let link: LinkLayer

    public init(inputTerminal: TerminalView, outputTerminal: TerminalView) {
        self.id             = NSUUID().uuidString
        self.inputTerminal  = inputTerminal
        self.outputTerminal = outputTerminal
        link = LinkLayer(terminals: (inputTerminal, outputTerminal))
    }
}

/*----------------------------------------------------------------------------*/

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.id == rhs.id
    }
}

/*----------------------------------------------------------------------------*/
public protocol NodeRepresenter {
    var id: String { get }
    var name: String { get }
    var rightAccessoryView: NSView? { get }
    var controlRows: [NodeRowRepresentable] { get }
    var inputs: [NodeProperty] { get }
    var outputs: [NodeProperty] { get }
}

open class Node: NSObject, NodeRepresenter {
    public let id: String
    public let name: String
    public let rightAccessoryView: NSView?
    public let controlRows: [NodeRowRepresentable]
    public private(set) var inputs: [NodeProperty]
    public private(set) var outputs: [NodeProperty]

    public init(name: String, rightAccessoryView: NSView? = nil, controlRows: [NodeRowRepresentable], inputs: [NodeProperty], outputs: [NodeProperty]) {
        self.id                 = NSUUID().uuidString
        self.name               = name
        self.rightAccessoryView = rightAccessoryView
        self.controlRows        = controlRows
        self.inputs             = inputs
        self.outputs            = outputs
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

public protocol GraphRepresenter {
    associatedtype C: ConnectionRepresenter
    associatedtype N: NodeRepresenter

    var nodes: [N] { get }
    var connections: [C] { get }
    func addConnection(_ connection: C)
    func removeConnection(_ connection: C)
    func addNode(_ node: N)
    func removeNode(_ node: N)
}

public class Graph: GraphRepresenter {
    public typealias C = Connection
    public typealias N = Node

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
        for connection in connections where (connection.input.node === node) || (connection.output.node === node) {
            removeConnection(connection)
        }
        nodes.removeAll(where: { $0 == node })
    }
}
