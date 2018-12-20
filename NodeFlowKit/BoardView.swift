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

    func drawLink(from startPoint: NSPoint, to endPoint: NSPoint, color: NSColor) {
        // Shadow vars & Swap depending on direction
        var startPoint = startPoint
        var endPoint   = endPoint
        if startPoint.x > endPoint.x {
            swap(&startPoint, &endPoint)
        }

        let threshold = max((endPoint.x - startPoint.x) / 2, 20)

        let p1 = NSMakePoint(startPoint.x + threshold, startPoint.y)
        let p2 = NSMakePoint(endPoint.x - threshold, endPoint.y)

        let path          = NSBezierPath()
        path.lineCapStyle = .round
        path.lineWidth    = 5

        path.move(to: startPoint)
        path.curve(to: endPoint, controlPoint1: p1, controlPoint2: p2)
        color.set()
        path.stroke()

        #if ENABLE_DEBUG_DRAW
        drawControlPoints([p1, p2], ofPoints: [startPoint, endPoint])
        #endif
    }

}

// MARK: - DEBUG Visualizations
extension BoardView {
    func drawControlPoints(_ controlPoints: [NSPoint], ofPoints points: [NSPoint]) {
        let color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.5)
        color.set()
        color.setFill()

        for (cp, p) in zip(controlPoints, points) {
            let circle = NSBezierPath(ovalIn: NSRect(x: cp.x - 2, y: cp.y - 2, width: 4, height: 4))
            circle.fill()
            let line = NSBezierPath()
            line.lineWidth = 1
            line.move(to: cp)
            line.line(to: p)
            line.stroke()
        }
    }
}
