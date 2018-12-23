//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class TestProperty: Property {
    var name: String
    var value: Any?
    init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
}

open class BoardViewController: NSViewController, BoardViewDelegate {

    typealias Conn = Connection

    fileprivate var boardView: BoardView!

    var graph: Graph! {
        didSet {
            boardView.graph = graph
            let nviews = graph.nodes.map(NodeView.init)
            nviews.forEach({ boardView.addSubview($0) })
            boardView.needsDisplay = true
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        boardView = BoardView(frame: view.bounds)
        boardView.graph = graph
        boardView.delegate = self
        view.addSubview(boardView)
    }

    override open func viewDidLayout() {
        super.viewDidLayout()
        boardView.frame = view.bounds
    }

    override open var representedObject: Any? {
        didSet {

        }
    }

    public func didConnect(output: Property, toInput: Property) {
        // User is responsible to add the connection to the graph
    }

}

