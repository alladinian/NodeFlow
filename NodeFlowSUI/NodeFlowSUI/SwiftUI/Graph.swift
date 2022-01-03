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

    @Published var name: String      = "Property"
    @Published var value: Any?       = nil
    @Published var frame: CGRect     = .zero
    @Published var isConnected: Bool = false
    @Published var isEnabled: Bool   = true

    var isInput: Bool                = true
    var hasSocket: Bool              = true
    var type: ContentType            = .number
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
    var cancellable: AnyCancellable?

    init?(output: NodeProperty, input: NodeProperty) {
        guard !output.isInput, input.isInput else { return nil }
        self.output = output
        self.input  = input
    }

    func setup() {
        [input, output].forEach { $0.isConnected = true }
        cancellable = output.$value
            .receive(on: RunLoop.main, options: nil)
            .assign(to: \.value, on: input)
    }

    func tearUp() {
        [input, output].forEach { $0.isConnected = false }
        cancellable?.cancel()
    }

    deinit {
        print("Deallocated \(self)")
    }
}

class LinkContext: ObservableObject {
    var start: CGPoint { sourceProperty?.frame.center ?? .zero }
    @Published var end: CGPoint   = .zero
    @Published var isActive: Bool = false
    @Published var sourceProperty: NodeProperty?
    @Published var destinationProperty: NodeProperty?
}

class Graph: Identifiable, ObservableObject {

    enum ConnectionError: LocalizedError {
        case sameNode
        case typeMismatch
        case inputOccupied

        var errorDescription: String? {
            switch self {
            case .sameNode:
                return "Attempted connection on the same node"
            case .typeMismatch:
                return "Property types do not match"
            case .inputOccupied:
                return "Input is already occupied"
            }
        }
    }

    var linkContext: LinkContext

    @Published var nodes: Set<Node>              = []
    @Published var connections: Set<Connection>  = []

    var cancellables: Set<AnyCancellable>        = []

    convenience init(nodes: Set<Node> = [], connections: Set<Connection> = []) {
        self.init()
        self.nodes       = nodes
        self.connections = connections
    }

    init() {
        self.linkContext = LinkContext()

        self.linkContext.$isActive
            .removeDuplicates()
            .combineLatest(self.linkContext.$sourceProperty, self.linkContext.$end)
            .receive(on: RunLoop.main, options: nil)
            .sink { [unowned self] isActive, source, end in
                // Started a line
                if isActive, let source = source {
                    // For outputs & unoccupied inputs always start a connection line
                    if !source.isInput || !source.isConnected {
                        // Nothing to do...
                    } else if let connection = connections.first(where: { $0.input == source }) {
                        let output = connection.output
                        removeConnection(connection)
                        linkContext.sourceProperty = output
                    }
                }
                // Ended a line
                else if let source = source {
                    attemptConnectionFrom(source, toPoint: end)
                }
            }
            .store(in: &cancellables)
    }

    private func attemptConnectionFrom(_ source: NodeProperty, toPoint destination: CGPoint) {
        for node in nodes.reversed() {
            for property in (node.inputs + node.outputs) where property.frame.contains(destination) {
                guard let connection = Connection(output: source.isInput ? property : source, input: source.isInput ? source : property) else { continue }

                do {
                    try addConnection(connection)
                } catch let error as ConnectionError {
                    switch error {
                    case .sameNode:
                        debugPrint(error)
                    case .typeMismatch:
                        debugPrint(error)
                    case .inputOccupied:
                        debugPrint(error)
                        // Find and remove the old connection
                        if let oldConnection = connections.first(where: { $0.input == property }) {
                            removeConnection(oldConnection)
                            attemptConnectionFrom(source, toPoint: destination)
                        }
                        return
                    }
                } catch {

                }

                return

            }
        }
    }

    func addConnection(_ connection: Connection) throws {
        let (input, output) = (connection.input, connection.output)

        // Reject if both are on the same node
        guard input.node != output.node else { throw ConnectionError.sameNode }

        // Reject if types don't match
        guard input.type.contains(output.type) else { throw ConnectionError.typeMismatch }

        // Reject if input is already occupied
        guard !input.isConnected else { throw ConnectionError.inputOccupied }

        connection.setup()
        connections.insert(connection)
    }

    func removeConnection(_ connection: Connection) {
        connection.tearUp()
        connections.remove(connection)
    }

    func addNode(_ node: Node) {
        nodes.insert(node)
    }

    func removeNode(_ node: Node) {
        let involvedConnections = connections.filter {
            ($0.input.node == node) || ($0.output.node == node)
        }
        for connection in involvedConnections {
            removeConnection(connection)
        }
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
