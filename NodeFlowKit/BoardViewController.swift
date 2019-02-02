//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class FlippedScrollView: NSScrollView {
    override var isFlipped: Bool { return true }

    open override func scrollWheel(with event: NSEvent) {
        guard event.modifierFlags.contains(.option) else { super.scrollWheel(with: event); return }
        let pt = documentView?.convert(event.locationInWindow, from: nil)
        var by: CGFloat = event.scrollingDeltaY * 0.001 // The smallest pinch-zoom amount seems to be about 0.002, but that was a bit too coarse.
        if !event.hasPreciseScrollingDeltas {
            by *= verticalLineScroll
        }
        setMagnification(magnification + by, centeredAt: pt ?? .zero)
    }
}

open class BoardViewController: NSViewController, BoardViewDelegate {

    fileprivate var scrollView = FlippedScrollView(frame: .zero)
    public var boardView = BoardView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))

    public var graph: Graph! {
        didSet {
            boardView.reloadData()
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller   = true
        scrollView.allowsMagnification   = true

        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.datasource                                = self
        boardView.delegate                                  = self

        scrollView.documentView = boardView
        view.addSubview(scrollView)
        boardView.reloadData()
    }

    override open func viewDidLayout() {
        super.viewDidLayout()
        scrollView.frame = view.bounds
    }

    override open var representedObject: Any? {
        didSet {

        }
    }

    @objc open func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) -> Bool {
        return terminal.isInput != otherTerminal.isInput
            && Connection.isProperty(terminal.property, compatibleWith: otherTerminal.property)
            && terminal.property.node != otherTerminal.property.node
    }

    @objc open func didConnect(_ inputTerminal: TerminalView, to outputTerminal: TerminalView) {
        if let existingConnection = graph.connections.first(where: { $0.inputTerminal === inputTerminal }) {
            didDisconnect(existingConnection.inputTerminal, from: existingConnection.outputTerminal)
        }
        let connection = Connection(inputTerminal: inputTerminal, outputTerminal: outputTerminal)
        graph.addConnection(connection)
    }

    @objc open func didDisconnect(_ inputTerminal: TerminalView, from outputTerminal: TerminalView) {
        guard let connection = graph.connections.first(where: { $0.inputTerminal == inputTerminal && $0.outputTerminal == outputTerminal }) else {
            print("Connection not found")
            return
        }
        graph.removeConnection(connection)
    }

    public func addNode(_ node: Node, at point: CGPoint) {
        graph.addNode(node)
        boardView.addNodeAtIndex(graph.nodes.endIndex - 1, at: point)
    }

    @objc public func removeNodeWithID(_ id: String?) {
        guard let id = id, let node = graph.nodes.first(where: { $0.id == id }) else { return }
        graph.removeNode(node)
        // Removes itself from the boardview
    }

    open func allowedDraggedTypes() -> [NSPasteboard.PasteboardType] {
        return []
    }

    open func didDropWithInfo(_ info: NSDraggingInfo) {}

}

extension BoardViewController: BoardViewDatasource {
    func numberOfNodeViews() -> Int {
        return graph?.nodes.count ?? 0
    }

    func numberOfConnections() -> Int {
        return graph?.connections.count ?? 0
    }

    func nodeViewForIndex(_ index: Int) -> NodeView {
        let node = graph.nodes[index]
        return NodeView(node: node)
    }

    func terminalViewsForNodeAtIndex(_ index: Int) -> [TerminalView] {
        return boardView.nodeViews[index].terminals
    }

    func terminalViewsForConnectionAtIndex(_ index: Int) -> (a: TerminalView, b: TerminalView)? {
        guard index < graph.connections.endIndex else { return nil }
        let connection = graph.connections[index]
        return (connection.inputTerminal, connection.outputTerminal)
    }
}
