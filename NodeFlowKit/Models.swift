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

func asIO(_ a: NodeProperty, _ b: NodeProperty) -> (input: NodeProperty, output: NodeProperty) {
    return ((a.isInput ? a : b), (!a.isInput ? a : b))
}

/*----------------------------------------------------------------------------*/

public class Connection: NSObject, ConnectionRepresenter {
    public weak var inputTerminal: TerminalView!
    public weak var outputTerminal: TerminalView!
    public var input: NodeProperty { return inputTerminal.property }
    public var output: NodeProperty { return outputTerminal.property }
    public let link: LinkLayer

    public init(inputTerminal: TerminalView, outputTerminal: TerminalView) {
        self.inputTerminal  = inputTerminal
        self.outputTerminal = outputTerminal
        link = LinkLayer(terminals: (inputTerminal, outputTerminal))
    }
}

/*----------------------------------------------------------------------------*/

open class Node: NSObject, NodeRepresenter {
    public var origin: CGPoint?
    public let name: String
    public let rightAccessoryView: NSView?
    public let controlRows: [NodeRowRepresentable]
    public private(set) var inputs: [NodeProperty]
    public private(set) var outputs: [NodeProperty]

    public init(name: String, rightAccessoryView: NSView? = nil, controlRows: [NodeRowRepresentable], inputs: [NodeProperty], outputs: [NodeProperty]) {
        self.name               = name
        self.rightAccessoryView = rightAccessoryView
        self.controlRows        = controlRows
        self.inputs             = inputs
        self.outputs            = outputs
        self.origin             = nil
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

public class Graph: GraphRepresenter {
    public fileprivate(set) var nodes: [NodeRepresenter]
    public fileprivate(set) var connections: [ConnectionRepresenter]

    public init(nodes: [Node], connections: [Connection] = []) {
        self.nodes       = nodes
        self.connections = connections
    }

    public func createConnection(inputTerminal: TerminalView, outputTerminal: TerminalView) {
        let connection = Connection(inputTerminal: inputTerminal, outputTerminal: outputTerminal)
        addConnection(connection)
    }

    public func addConnection(_ connection: ConnectionRepresenter) {
        connections.append(connection)
    }

    public func removeConnection(_ connection: ConnectionRepresenter) {
        connections.removeAll(where: { $0 === connection })
    }

    public func addNode(_ node: NodeRepresenter) {
        nodes.append(node)
    }

    public func removeNode(_ node: NodeRepresenter) {
        for connection in connections where (connection.input.node === node) || (connection.output.node === node) {
            removeConnection(connection)
        }
        nodes.removeAll(where: { $0 === node })
    }
}
