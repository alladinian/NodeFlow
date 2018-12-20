//
//  BoardView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class BoardView: NSView {

    var gridBaseColor: NSColor = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)
    var gridSpacing: Int       = 10
    var bgColor: NSColor       = NSColor.windowBackgroundColor

    var graph: Graph?

    var connectionPairs: [(c1: ConnectionView, c2: ConnectionView)] = []

    var nodeViews: [NodeView] {
        return subviews.compactMap({ $0 as? NodeView })
    }

    public override var isFlipped: Bool { return true }
    public override var acceptsFirstResponder: Bool { return true }
    public override var wantsUpdateLayer: Bool { return false }

    // Lines
    fileprivate var initialMousePoint: CGPoint!
    fileprivate var lastMousePoint: CGPoint!
    fileprivate var isDrawingLine: Bool = false

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    public override func draw(_ rect: NSRect) {
        super.draw(rect)

        let context = NSGraphicsContext.current?.cgContext

        // BG drawing
        bgColor.setFill()
        context?.fill(rect)

        // Grid drawing
        drawGrid()

        // Lines drawing
        if isDrawingLine {
            drawLink(from: initialMousePoint, to: lastMousePoint, color: gridBaseColor)
        }

        for pair in connectionPairs {
            let c1 = pair.c1
            let c2 = pair.c2
            let c1f = convert(c1.frame, from: c1.superview)
            let c2f = convert(c2.frame, from: c2.superview)
            drawLink(from: CGPoint(x: c1f.midX, y: c1f.midY), to: CGPoint(x: c2f.midX, y: c2f.midY), color: gridBaseColor)
        }
    }

}

// MARK: - Grid drawing
extension BoardView {

    fileprivate var verticalSteps: Int {
        return Int(bounds.size.height) / gridSpacing
    }

    fileprivate var horizontalSteps: Int {
        return Int(bounds.size.width) / gridSpacing
    }

    fileprivate func drawGrid() {
        func colorForStep(_ step: Int) -> NSColor {
            let stops: [(n: Int, a: CGFloat)] = [(10, 0.3), (5, 0.2)]
            let alpha: CGFloat = stops.lazy.first(where : { step.isMultipleOf($0.n) })?.a ?? 0.1
            return gridBaseColor.withAlphaComponent(alpha)
        }

        func pointsForStep(_ step: Int, isVertical: Bool) -> (start: CGPoint, end: CGPoint) {
            let position = CGFloat(step) * 10 - 0.5
            let start    = CGPoint(x: isVertical ? 0 : position, y: isVertical ? position : 0)
            let end      = CGPoint(x: isVertical ? bounds.width : position, y: isVertical ? position : bounds.height)
            return (start, end)
        }

        guard verticalSteps > 1, horizontalSteps > 1 else { return }

        // Vertical Steps ↓
        for step in 1...verticalSteps {
            colorForStep(step).set()
            let points = pointsForStep(step, isVertical: true)
            NSBezierPath.strokeLine(from: points.start, to: points.end)
        }

        // Horizontal Steps →
        for step in 1...horizontalSteps {
            colorForStep(step).set()
            let points = pointsForStep(step, isVertical: false)
            NSBezierPath.strokeLine(from: points.start, to: points.end)
        }
    }

}

// MARK: - Event Handling
extension BoardView {

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        initialMousePoint = convert(event.locationInWindow, from: nil)
        lastMousePoint    = initialMousePoint
    }

    public override func mouseDragged(with event: NSEvent) {
        isDrawingLine  = true
        lastMousePoint = convert(event.locationInWindow, from: nil)
        if initialMousePoint == nil {
            initialMousePoint = lastMousePoint
        }
        needsDisplay = true
    }

    public override func mouseUp(with event: NSEvent) {
        isDrawingLine = false
        needsDisplay  = true

        var c1: ConnectionView?
        var c2: ConnectionView?

        for connection in nodeViews.flatMap({ $0.connections }) {
            if convert(connection.frame, from: connection.superview).contains(initialMousePoint) {
                c1 = connection
            }

            if convert(connection.frame, from: connection.superview).contains(lastMousePoint) {
                c2 = connection
            }
        }

        if let c1 = c1, let c2 = c2, c1.isInput != c2.isInput {
            connectionPairs.append((c1, c2))
        }
    }

    func threshold(_ x: CGFloat, _ tr: CGFloat) -> CGFloat {
        return (x > 0) ? ((x > tr) ? x : tr) : -x + tr
    }

    func drawLink(from startPoint: NSPoint, to endPoint: NSPoint, color: NSColor) {
        let resolvedThreshold = threshold((endPoint.x - startPoint.x) / 2, 20)

        // Force Direction
        var startPoint = startPoint
        var endPoint = endPoint
        if startPoint.x > endPoint.x {
            swap(&startPoint, &endPoint)
        }

        let p0 = NSMakePoint(startPoint.x, startPoint.y)
        let p3 = NSMakePoint(endPoint.x, endPoint.y)
        let p1 = NSMakePoint(startPoint.x + resolvedThreshold, startPoint.y)
        let p2 = NSMakePoint(endPoint.x - resolvedThreshold, endPoint.y)

        // p0 and p1 are on the same horizontal line
        // distance between p0 and p1 is set with the threshold fuction
        // the same holds for p2 and p3
        let path          = NSBezierPath()
        path.lineCapStyle = .round
        path.lineWidth    = 5
        path.move(to: p0)
        path.curve(to: p3, controlPoint1: p1, controlPoint2: p2)
        color.set()
        path.stroke()
    }

}
