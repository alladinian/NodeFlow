//
//  Protocols.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

//MARK: BoardView Delegate Protocol
public protocol BoardViewDelegate: class {
    func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) -> Bool
    func didConnect(_ inputTerminal: TerminalView, to outputTerminal: TerminalView)
    func didDisconnect(_ inputTerminal: TerminalView, from outputTerminal: TerminalView)
    func allowedDraggedTypes() -> [NSPasteboard.PasteboardType]
    func didDropWithInfo(_ info: NSDraggingInfo)
}

//MARK: - NodeRow Protocol & Extension for NSView
public protocol NodeRowRepresentable {}
extension NSView: NodeRowRepresentable {}

//MARK: - NodeProperty Protocol
public protocol NodeProperty: NodeRowRepresentable {
    var name: String { get set }
    var value: Any? { get set }
    var controlView: NSView { get set }
    var topAccessoryView: NSView? { get set }
    var bottomAccessoryView: NSView? { get set }
    var isInput: Bool { get }
    var type: ContentType { get }
    var node: NodeRepresenter! { get set }
}

public func arePropertiesCompatible(_ a: NodeProperty, _ b: NodeProperty) -> Bool {
    let (input, output) = asIO(a, b)
    return input.type.isSuperset(of: output.type)
}

//MARK: - Connection Protocol
public protocol ConnectionRepresenter: Equatable {
    var inputTerminal: TerminalView! { get }
    var outputTerminal: TerminalView! { get }
    var input: NodeProperty { get }
    var output: NodeProperty { get }
    var link: LinkLayer { get }
}

//MARK: - Node Protocol
public protocol NodeRepresenter: NSObjectProtocol {
    var id: String { get }
    var name: String { get }
    var rightAccessoryView: NSView? { get }
    var controlRows: [NodeRowRepresentable] { get }
    var inputs: [NodeProperty] { get }
    var outputs: [NodeProperty] { get }
}

//MARK: - Graph Protocol
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
