//
//  ViewController.swift
//  NodeFlow
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa
import NodeFlowKit
import SceneKit

class ViewController: BoardViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        graph = BaseGraph(nodes: [Node.mathNode(), Node.mathNode(), Node.mathNode()], connections: [])
    }

    override var representedObject: Any? {
        didSet {
        
        }
    }


}

