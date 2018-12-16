//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class BoardController: NSViewController {

    fileprivate var boardView: BoardView!

    override func viewDidLoad() {
        super.viewDidLoad()
        boardView = BoardView(frame: view.bounds)
        view.addSubview(boardView)
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
