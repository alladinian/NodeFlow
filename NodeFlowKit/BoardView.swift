//
//  BoardView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class BoardView: NSView {

    fileprivate let gridView = GridView(frame: .zero)

    var nodes: [NodeView] {
        return subviews.compactMap({ $0 as? NodeView })
    }

    public override var isFlipped: Bool { return true }

    public override var wantsUpdateLayer: Bool { return false }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        addSubview(gridView)
    }

    public override var frame: NSRect {
        didSet {
            gridView.frame = bounds
        }
    }

    public override func updateLayer() {
        super.updateLayer()
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        gridView.needsDisplay = true
    }

}
