//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class ConnectionView: NSView {

    let ring = CALayer()
    let circle = CALayer()

    var isConnected: Bool   = false
    var isHighlighted: Bool = false
    var isInput: Bool!

    convenience init() {
        self.init(frame: NSRect(x: 0, y: 0, width: 14, height: 14))
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

        ring.frame = bounds
        ring.cornerRadius = ring.bounds.midY
        ring.borderColor = NSColor.controlAccentColor.cgColor
        ring.borderWidth = 2
        layer?.addSublayer(ring)

        circle.frame           = bounds.insetBy(dx: 4, dy: 4)
        circle.backgroundColor = NSColor.controlAccentColor.cgColor
        circle.cornerRadius    = circle.bounds.midY
        layer?.addSublayer(circle)

        widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        circle.opacity = 0.0
    }

    override public func updateTrackingAreas() {
        for trackingArea in trackingAreas {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }

    public override func mouseEntered(with event: NSEvent) {
        isHighlighted = true
        circle.opacity = isConnected ? 1.0 : 0.5
    }

    public override func mouseExited(with event: NSEvent) {
        isHighlighted = false
        circle.opacity = isConnected ? 1.0 : 0.0
    }
}
