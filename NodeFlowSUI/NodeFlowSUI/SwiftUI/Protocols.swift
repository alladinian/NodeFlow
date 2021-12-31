//
//  Protocols.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import SwiftUI

class NodeProperty: Identifiable {
    var name: String      = ""
    var value: Any?       = nil
    var isInput: Bool     = false
    var type: ContentType = .number
}

class Node: Identifiable, Hashable {

    var name: String            = ""
    var inputs: [NodeProperty]  = []
    var outputs: [NodeProperty] = []
    var position: CGPoint       = .zero

    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class Connection: Identifiable, Hashable {
    var input: NodeProperty
    var output: NodeProperty

    init(input: NodeProperty, output: NodeProperty) {
        self.input  = input
        self.output = output
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class Graph: Identifiable {
    var nodes: Set<Node>              = []
    var connections: Set<Connection>  = []

    func shouldAddConnection(_ connection: Connection) -> Bool {
        return true
    }

    func addConnection(_ connection: Connection) {
        connections.insert(connection)
    }

    func removeConnection(_ connection: Connection) {
        connections.remove(connection)
    }

    func addNode(_ node: Node) {
        nodes.insert(node)
    }

    func removeNode(_ node: Node) {
        nodes.remove(node)
    }
}


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

    public static var imageContent: ContentType {
        return [.image, .url]
    }

    public static var materialContent: ContentType {
        return [.color, .number, .image, .string, .url, .video, .calayer, .texture, .scene, .cubeMap]
    }

    public var associatedColors: [Color] {
        return elements().map { element in
            switch element {
            case .vector, .vectorImage: return .purple
            case .number:               return .gray
            default:                    return .yellow
            }
        }
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension OptionSet where RawValue: FixedWidthInteger {
    func elements() -> AnySequence<Self> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnySequence {
            return AnyIterator {
                while remainingBits != 0 {
                    defer { bitMask = bitMask &* 2 }
                    if remainingBits & bitMask != 0 {
                        remainingBits = remainingBits & ~bitMask
                        return Self(rawValue: bitMask)
                    }
                }
                return nil
            }
        }
    }
}
