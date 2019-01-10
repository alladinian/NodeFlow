//
//  Protocols.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

protocol BoardViewDatasource: class {
    func numberOfNodeViews() -> Int
    func numberOfConnections() -> Int
    func nodeViewForIndex(_ index: Int) -> NodeView
    func terminalViewsForNodeAtIndex(_ index: Int) -> [TerminalView]
    func terminalViewsForConnectionAtIndex(_ index: Int) -> (a: TerminalView, b: TerminalView)
}

protocol BoardViewDelegate: class {
    func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView)
    func didConnect(_ terminal: TerminalView, to otherTerminal: TerminalView)
    func didDisconnect(_ terminal: TerminalView, from otherTerminal: TerminalView)
}
