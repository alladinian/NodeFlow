//
//  Protocols.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

//MARK: BoardView Rendering Datasource Protocol
public protocol BoardViewRenderingDatasource: AnyObject {
    func rightAccessoryViewForNode(_ node: NodeRepresenter) -> NSView?
    func controlRowsForNode(_ node: NodeRepresenter) -> [NodeRowRepresentable]
    func controlViewForProperty(_ property: NodeProperty) -> NSView
    func topAccessoryViewForProperty(_ property: NodeProperty) -> NSView?
    func bottomAccessoryViewForProperty(_ property: NodeProperty) -> NSView?
}

//MARK: BoardView Delegate Protocol
public protocol BoardViewDelegate: AnyObject {
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
public protocol NodeProperty: NSObjectProtocol, NodeRowRepresentable {
    var name: String { get }
    var value: Any? { get set }
    var isInput: Bool { get }
    var type: ContentType { get }
    var node: NodeRepresenter! { get set }
}

public func arePropertiesCompatible(_ a: NodeProperty, _ b: NodeProperty) -> Bool {
    guard let (input, output) = asIO(a, b) else { return false }
    return input.type.isSuperset(of: output.type)
}

//MARK: - Connection Protocol
public protocol ConnectionRepresenter: NSObjectProtocol {
    var input: NodeProperty { get }
    var output: NodeProperty { get }
}

//MARK: - Node Protocol
public protocol NodeRepresenter: NSObjectProtocol {
    var name: String { get }
    var inputs: [NodeProperty] { get }
    var outputs: [NodeProperty] { get }
    var origin: CGPoint? { get set }
}

//MARK: - Graph Protocol
public protocol GraphRepresenter {
    var nodes: [NodeRepresenter] { get }
    var connections: [ConnectionRepresenter] { get }
    func createConnection(inputTerminal: TerminalView, outputTerminal: TerminalView)
    func addConnection(_ connection: ConnectionRepresenter)
    func removeConnection(_ connection: ConnectionRepresenter)
    func addNode(_ node: NodeRepresenter)
    func removeNode(_ node: NodeRepresenter)
}


/*----------------------------------------------------------------------------*/
func asIO(_ a: TerminalView, _ b: TerminalView) -> (input: TerminalView, output: TerminalView)? {
    guard a.isInput != b.isInput else { return nil }
    return ((a.isInput ? a : b), (!a.isInput ? a : b))
}

func asIO(_ a: NodeProperty, _ b: NodeProperty) -> (input: NodeProperty, output: NodeProperty)? {
    guard a.isInput != b.isInput else { return nil }
    return ((a.isInput ? a : b), (!a.isInput ? a : b))
}
