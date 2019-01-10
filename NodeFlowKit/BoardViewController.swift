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
            boardView.reloadData()
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



    public func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) {
        
    }

    public func didConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) {
        let connection = Connection(input: terminal.property, output: otherTerminal.property)
        graph.addConnection(connection)
    }

    public func didDisconnect(_ terminal: TerminalView, from otherTerminal: TerminalView) {

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
        return []
    }

    func terminalViewsForConnectionAtIndex(_ index: Int) -> (a: TerminalView, b: TerminalView) {
        fatalError()
    }
}
