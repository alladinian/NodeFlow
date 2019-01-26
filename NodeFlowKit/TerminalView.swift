//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class TerminalView: NSView {

    let ring   = CALayer()
    let circle = CALayer()

    var isConnected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    var isHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    var isInput: Bool!

    weak var property: NodeProperty!

    public override var wantsUpdateLayer: Bool {
        return true
    }

    init(property: NodeProperty) {
        super.init(frame: NSRect(x: 0, y: 0, width: 14, height: 14))
        self.property = property
        commonInit()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    func commonInit() {
        wantsLayer = true

        ring.frame        = bounds
        ring.cornerRadius = ring.bounds.midY
        ring.borderColor  = ThemeColor.connectionBorder.cgColor
        ring.borderWidth  = 2
        layer?.addSublayer(ring)

        circle.frame           = bounds.insetBy(dx: 4, dy: 4)
        circle.backgroundColor = ThemeColor.connection.cgColor
        circle.cornerRadius    = circle.bounds.midY
        layer?.addSublayer(circle)

        widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        circle.opacity = 0.0
    }

    override public func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self)
        addTrackingArea(trackingArea)
    }

    public override func mouseEntered(with event: NSEvent) {
        isHighlighted = true
    }

    public override func mouseExited(with event: NSEvent) {
        isHighlighted = false
    }

    public override func updateLayer() {
        super.updateLayer()
        if isHighlighted {
            circle.opacity = isConnected ? 1.0 : 0.5
        } else {
            circle.opacity = isConnected ? 1.0 : 0.0
        }
    }

}
