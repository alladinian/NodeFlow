//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

open class BoardViewController: NSViewController, BoardViewDelegate {

    fileprivate var boardView: BoardView!

    public var graph: Graph! {
        didSet {
            boardView?.reloadData()
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        boardView = BoardView(frame: view.bounds)
        boardView.datasource = self
        boardView.delegate = self
        view.addSubview(boardView)
        boardView.reloadData()
    }

    override open func viewDidLayout() {
        super.viewDidLayout()
        boardView.frame = view.bounds
    }

    override open var representedObject: Any? {
        didSet {

        }
    }

    @objc open func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) -> Bool {
        return true
    }

    @objc open func didConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) {
        let connection = Connection(input: terminal.property, inputTerminal: terminal, output: otherTerminal.property, outputTerminal: otherTerminal)
        graph.addConnection(connection)
    }

    @objc open func didDisconnect(_ terminal: TerminalView, from otherTerminal: TerminalView) {

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
