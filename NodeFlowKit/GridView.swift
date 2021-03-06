//
//  GridView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class GridView: NSView {

    fileprivate var initialMousePoint: CGPoint!
    fileprivate var lastMousePoint: CGPoint!
    fileprivate var isDrawingLine: Bool = false

    public override var isFlipped: Bool { return true }

    var bgColor: NSColor = {
        // Dynamic based on user's system prefs (dark/light)
        return NSColor.windowBackgroundColor
    }()

    var baseColor: NSColor = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)
    var spacing: Int       = 10

    public override var acceptsFirstResponder: Bool { return true }

    fileprivate var verticalSteps: Int {
        return Int(bounds.size.height) / spacing
    }

    fileprivate var horizontalSteps: Int {
        return Int(bounds.size.width) / spacing
    }

    fileprivate func drawGrid() {
        func colorForStep(_ step: Int) -> NSColor {
            let stops: [(n: Int, a: CGFloat)] = [(10, 0.3), (5, 0.2)]
            let alpha: CGFloat = stops.lazy.first(where : { step.isMultipleOf($0.n) })?.a ?? 0.1
            return baseColor.withAlphaComponent(alpha)
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


    override public func draw(_ rect: NSRect) {
        super.draw(rect)

        let context = NSGraphicsContext.current?.cgContext

        bgColor.setFill()
        context?.fill(rect)
        context?.flush()

        drawGrid()

        if isDrawingLine {
            drawLink(from: initialMousePoint, to: lastMousePoint, color: baseColor)
        }

        for pair in connectionPairs {
            let c1 = pair.c1
            let c2 = pair.c2
            let c1f = convert(c1.frame, from: c1.superview)
            let c2f = convert(c2.frame, from: c2.superview)
            drawLink(from: CGPoint(x: c1f.midX, y: c1f.midY), to: CGPoint(x: c2f.midX, y: c2f.midY), color: baseColor)
        }

    }

    var connectionPairs: [(c1: ConnectionView, c2: ConnectionView)] = []

}

// MARK: - Event Handling
extension GridView {

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        initialMousePoint = superview!.convert(event.locationInWindow, from: nil)
        lastMousePoint    = initialMousePoint
    }

    public override func mouseDragged(with event: NSEvent) {
        isDrawingLine  = true
        lastMousePoint = superview!.convert(event.locationInWindow, from: nil)
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

        for connection in (superview as? BoardView)?.nodes.flatMap({ $0.connections }) ?? [] {
            if convert(connection.frame, from: connection.superview).contains(initialMousePoint) {
                c1 = connection
            }

            if convert(connection.frame, from: connection.superview).contains(lastMousePoint) {
                print("Found last connection: \(connection)")
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
        let resolvedThreshold = threshold((endPoint.x - startPoint.x) / 2, 50)

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
