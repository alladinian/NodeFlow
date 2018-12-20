//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class TestProperty: Property {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class BoardController: NSViewController, BoardViewDelegate {

    fileprivate var boardView: BoardView!

    #warning("Test graph")
    var graph: Graph = {
        var nodes: [Node] = []
        for _ in 1...2 {
            let inputs = [TestProperty(name: "InputProperty"), TestProperty(name: "OtherInputProperty")]
            let outputs = [TestProperty(name: "Output")]
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

