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
}

class ColorGridView: NSView {
    static let color = NSColor(patternImage: GridView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).image())
    override func draw(_ dirtyRect: NSRect) {
        let theContext = NSGraphicsContext.current
        theContext?.saveGraphicsState()
        theContext?.patternPhase = NSMakePoint(0, frame.size.height)
        ColorGridView.color.set()
        bounds.fill()
        theContext?.restoreGraphicsState()
    }
}

open class BoardViewController: NSViewController, BoardViewDelegate {

    fileprivate var scrollView = FlippedScrollView(frame: .zero)
    fileprivate var boardView = BoardView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))

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
        view = ColorGridView()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        scrollView.drawsBackground       = false
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

    func terminalViewsForConnectionAtIndex(_ index: Int) -> (a: TerminalView, b: TerminalView) {
        let connection = graph.connections[index]
        return (connection.inputTerminal, connection.outputTerminal)
    }
}
