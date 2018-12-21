//
//  BoardView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public protocol BoardViewDelegate: class {
    func didConnect(_ input: ConnectionView, to output: ConnectionView)
}

public class BoardView: NSView {

    var gridBaseColor: NSColor = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)
    var gridSpacing: Int       = 10
    var bgColor: NSColor       = NSColor.windowBackgroundColor
    var selectionColor         = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.937254902, alpha: 1)

    // Selection variables
    fileprivate var startPoint: NSPoint!
    fileprivate var selectionLayer:  CAShapeLayer = {
        let selectionLayer = CAShapeLayer()
        selectionLayer.lineWidth   = 1.0
        selectionLayer.fillColor   = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.937254902, alpha: 1).withAlphaComponent(0.4).cgColor
        selectionLayer.strokeColor = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.937254902, alpha: 1)
        return selectionLayer
    }()

    fileprivate var isSelectingWithRectangle = false


    weak var delegate: BoardViewDelegate?

    var graph: Graph?

    var nodeViews: [NodeView] {
        return subviews.compactMap({ $0 as? NodeView })
    }

    var connectionViews: [ConnectionView] {
        return nodeViews.flatMap({ $0.connections })
    }

    public override var isFlipped: Bool { return true }
    public override var acceptsFirstResponder: Bool { return true }
    public override var wantsUpdateLayer: Bool { return false }
    public override var isOpaque: Bool { return true }

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

        // Interactive line drawing
        if isDrawingLine {
            drawLink(from: initialMousePoint, to: lastMousePoint)
        }

        // Selection drawing
        if isSelectingWithRectangle {
            drawSelection(from: initialMousePoint, to: lastMousePoint)
        }

        // Permament lines drawing
        for connection in graph?.connections ?? [] {
            let input = connection.input
            let output = connection.output
            if let inputView = connectionViews.lazy.first(where: { $0.property === input }), let outputView = connectionViews.lazy.first(where: { $0.property === output }) {
                let c1f = convert(inputView.frame, from: inputView.superview)
                let c2f = convert(outputView.frame, from: outputView.superview)
                drawLink(from: CGPoint(x: c1f.midX, y: c1f.midY), to: CGPoint(x: c2f.midX, y: c2f.midY))
            }
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

        // If we're on top of a connectionView start drawing a line
        for connection in connectionViews {
            if convert(connection.frame, from: connection.superview).contains(initialMousePoint) {
                isDrawingLine  = true
                break
            }
        }

        if !isDrawingLine {
            isSelectingWithRectangle = true
        }
    }

    public override func mouseDragged(with event: NSEvent) {
        lastMousePoint = convert(event.locationInWindow, from: nil)
        if initialMousePoint == nil {
            initialMousePoint = lastMousePoint
        }
        needsDisplay = true
    }

    public override func mouseUp(with event: NSEvent) {
        isDrawingLine = false
        isSelectingWithRectangle = false
        needsDisplay  = true

        var c1: ConnectionView?
        var c2: ConnectionView?

        for connection in connectionViews {
            if convert(connection.frame, from: connection.superview).contains(initialMousePoint) {
                c1 = connection
            }

            if convert(connection.frame, from: connection.superview).contains(lastMousePoint) {
                c2 = connection
            }
        }

        if let c1 = c1, let c2 = c2, c1.isInput != c2.isInput {
            let input = c1.isInput ? c1 : c2
            let output = !c1.isInput ? c1 : c2
            delegate?.didConnect(input, to: output)
        }
    }

    func drawLink(from startPoint: NSPoint, to endPoint: NSPoint) {
        let color = gridBaseColor
        // Shadow vars & Swap depending on direction
        var inputPoint = startPoint
        var outputPoint = endPoint

        if inputPoint.x > outputPoint.x {
            swap(&inputPoint, &outputPoint)
        }

        let threshold = max((outputPoint.x - inputPoint.x) / 2, 0)

        let p1 = NSMakePoint(inputPoint.x + threshold, inputPoint.y)
        let p2 = NSMakePoint(outputPoint.x - threshold, outputPoint.y)

        let path          = NSBezierPath()
        path.lineCapStyle = .round
        path.lineWidth    = 5

        path.move(to: inputPoint)
        path.curve(to: outputPoint, controlPoint1: p1, controlPoint2: p2)
        color.set()
        path.stroke()

        if ProcessInfo.processInfo.environment["debugDraw"] != nil {
            drawControlPoints([p1, p2], ofPoints: [inputPoint, outputPoint])
        }
    }

    func drawSelection(from startPoint: NSPoint, to endPoint: NSPoint) {
        let fillColor   = NSColor.controlAccentColor.withAlphaComponent(0.1)
        let strokeColor = NSColor.controlAccentColor
        // Draw the selection box
        let rect = NSMakeRect(min(startPoint.x, endPoint.x),
                              min(startPoint.y, endPoint.y),
                              abs(startPoint.x - endPoint.x),
                              abs(startPoint.y - endPoint.y))
        let path = NSBezierPath(rect: rect)
        path.lineWidth = 1.0
        fillColor.setFill()
        strokeColor.setStroke()
        path.fill()
        path.stroke()
    }

}

// MARK: - DEBUG Visualizations
extension BoardView {
    func drawControlPoints(_ controlPoints: [NSPoint], ofPoints points: [NSPoint]) {
        let color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.4)
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
