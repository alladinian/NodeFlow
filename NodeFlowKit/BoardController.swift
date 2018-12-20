//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

struct TestProperty: Property {
    let name: String
}

class BoardController: NSViewController {

    fileprivate var boardView: BoardView!

    var graph: Graph!

    override func viewDidLoad() {
        super.viewDidLoad()
        boardView = BoardView(frame: view.bounds)
        view.addSubview(boardView)

        var nodes: [Node] = []
        for _ in 1...2 {
            let props: [Property] = [TestProperty(name: "Property"), TestProperty(name: "OtherProperty")]
            let node = Node(inputs: props, outputs: props, evaluationFunction: {_ in })
            nodes.append(node)
        }

        graph = Graph(nodes: nodes, connections: [])

        let nviews = nodes.map(NodeView.init)
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

}
