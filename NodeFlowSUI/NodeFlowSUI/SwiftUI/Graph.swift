//
//  Graph.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class NodeProperty: Identifiable, ObservableObject {
    weak var node: Node?         = nil

    @Published var name: String  = "Property"
    @Published var value: Any?   = nil
    @Published var frame: CGRect = .zero

    var isInput: Bool            = true
    var isConnected: Bool        = false
    var hasSocket: Bool          = true
    var type: ContentType        = .number
}

class Node: Identifiable, ObservableObject {
    @Published var name: String      = "Node"
    @Published var position: CGPoint = .zero

    var cancellables: Set<AnyCancellable> = []

    var inputs: [NodeProperty] = [] {
        didSet {
            inputs.forEach {
                $0.node    = self
                $0.isInput = true
            }
        }
    }

    var outputs: [NodeProperty] = [] {
        didSet {
            outputs.forEach {
                $0.node    = self
                $0.isInput = false
            }
        }
    }
}

class Connection: Identifiable, ObservableObject {
    var input: NodeProperty
    var output: NodeProperty
    var cancellable: AnyCancellable

    init(output: NodeProperty, input: NodeProperty) {
        self.input       = input
        self.output      = output
        [self.input, self.output].forEach { $0.isConnected = true }
        self.cancellable = output.$value
            .receive(on: RunLoop.main, options: nil)
            .assign(to: \.value, on: input)
    }

    deinit {
        print("Deallocated \(self)")
    }
}


class Graph: Identifiable, ObservableObject {
    @Published var nodes: Set<Node>              = []
    @Published var connections: Set<Connection>  = []

    var cancellables: Set<AnyCancellable> = []

    convenience init(nodes: Set<Node> = [], connections: Set<Connection> = []) {
        self.init()
        self.nodes       = nodes
        self.connections = connections
    }

    init() {
        NotificationCenter.default
            .publisher(for: .didFinishDrawingLine, object: nil)
            .subscribe(on: RunLoop.main, options: nil)
            .sink { [unowned self] value in
                guard let value = value.object as? (source: NodeProperty, destination: CGPoint) else { return }
                for node in nodes.reversed() {
                    for property in (node.inputs + node.outputs)
                    where property.frame.contains(value.destination) && shouldAddConnection(betweenProperty: value.source, and: property) {
                        let connection = Connection(output: value.source.isInput ? property : value.source,
                                                    input: value.source.isInput ? value.source : property)
                        addConnection(connection)
                        return
                    }
                }
            }
            .store(in: &cancellables)
    }

    func shouldAddConnection(betweenProperty a: NodeProperty, and b: NodeProperty) -> Bool {
        guard a.isInput != b.isInput else { return false }
        guard a.node != b.node else { return false}
        return true
    }

    func addConnection(_ connection: Connection) {
        connections.insert(connection)
    }

    func removeConnection(_ connection: Connection) {
        connection.cancellable.cancel()
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
    public static let picker      = ContentType(rawValue: 1<<12)

    public static var imageContent: ContentType {
        return [.image, .url]
    }

    public static var materialContent: ContentType {
        return [.color, .number, .image, .string, .url, .video, .calayer, .texture, .scene, .cubeMap]
    }

    public var associatedColors: [Color] {
        elements().map { element in
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

//MARK: - Extensions

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

extension Connection: Hashable {
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension NodeProperty: Equatable, Hashable {
    static func == (lhs: NodeProperty, rhs: NodeProperty) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
