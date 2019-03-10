//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class TerminalView: NSView {

    var rings  = [CALayer]()
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
    var isOutput: Bool {
        get { return !isInput }
        set { isInput = !newValue }
    }

    public var property: NodeProperty!

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

        if wantsUpdateLayer {
            layerContentsRedrawPolicy = .onSetNeedsDisplay
        }

        let colors = Set(property.type.associatedColors)

        for (index, color) in colors.enumerated() {
            let ring         = CAShapeLayer()
            let rect         = bounds.insetBy(dx: 2, dy: 2)
            ring.path        = CGPath(ellipseIn: rect, transform: nil)
            ring.bounds      = rect
            ring.strokeColor = color.cgColor
            ring.lineWidth   = 2
            ring.fillColor   = NSColor.clear.cgColor
            let step         = 1.0 / CGFloat(colors.count)
            ring.strokeStart = CGFloat(index) * step
            ring.strokeEnd   = ring.strokeStart + step
            ring.transform   = CATransform3DMakeRotation(CGFloat.pi/2, 0, 0, 1)
            ring.position    = CGPoint(x: bounds.midX, y: bounds.midY)
            rings.append(ring)
            layer?.addSublayer(ring)
        }

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
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .enabledDuringMouseDrag], owner: self)
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
