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

class BoardController: NSViewController, BoardViewDelegate {

    fileprivate var boardView: BoardView!

    #warning("Test graph")
    var graph: Graph = {
        var nodes: [Node] = []
        for _ in 1...4 {
            let inputs = [TestProperty(name: "InputProperty", value: 0.0), TestProperty(name: "OtherInputProperty", value: 1.0)]
            let outputs = [TestProperty(name: "Output", value: 0)]
            let node = Node(inputs: inputs, outputs: outputs, evaluationFunction: {_ in })
            nodes.append(node)
        }

        return Graph(nodes: nodes, connections: [])
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        boardView = BoardView(frame: view.bounds)
        boardView.graph = graph
        boardView.delegate = self
        view.addSubview(boardView)

        let nviews = graph.nodes.map(NodeView.init)
        nviews.forEach({ boardView.addSubview($0) })
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        boardView.frame = view.bounds
    }

    override var representedObject: Any? {
        didSet {

        }
    }

    func didConnect(_ input: ConnectionView, to output: ConnectionView) {
        let connection = Connection(input: input.property, output: output.property)
        input.isConnected = true
        output.isConnected = true
        graph.addConnection(connection)
    }

}

