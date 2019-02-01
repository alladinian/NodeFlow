//
//  BoardView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class BoardView: NSView {

    // Selection variables
    fileprivate var startPoint: NSPoint!
    fileprivate var isSelectingWithRectangle = false

    weak var datasource: BoardViewDatasource?
    weak var delegate: BoardViewDelegate?

    var nodeViews: [NodeView] {
        return subviews.compactMap({ $0 as? NodeView })
    }

    var terminalViews: [TerminalView] {
        return nodeViews.flatMap({ $0.terminals })
    }

    public override var isFlipped: Bool { return true }
    public override var acceptsFirstResponder: Bool { return true }
    public override var wantsUpdateLayer: Bool { return false }
    public override var isOpaque: Bool { return false }

    // Lines
    fileprivate var initialMousePoint: CGPoint!
    fileprivate var lastMousePoint: CGPoint!
    fileprivate var isDrawingLine: Bool = false

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    func commonInit() {

    }

    public override var frame: NSRect {
        didSet {

        }
    }

    public override func viewDidMoveToSuperview() {
        reloadData()
    }

    public func reloadData() {
        needsDisplay = true
        guard let datasource = datasource else { return }

        nodeViews.forEach({ $0.removeFromSuperview() })

        for index in 0..<datasource.numberOfNodeViews() {
            let nodeView = datasource.nodeViewForIndex(index)
            addSubview(nodeView)
            nodeView.frame.origin = CGPoint(x: CGFloat(index) * 200 + 20, y: 20)
            #warning("Fixme")
        }
    }

    public override func draw(_ rect: NSRect) {
        super.draw(rect)

        // BG drawing
        //ThemeColor.background.setFill()
        NSColor.clear.set()
        rect.fill(using: .sourceOver)

        // Interactive line drawing
        var initiatingTerminal: TerminalView?
        if isDrawingLine {

            initiatingTerminal = terminalForPoint(initialMousePoint)

            for index in 0..<(datasource?.numberOfConnections() ?? 0) {
                if let (t1, t2) = datasource?.terminalViewsForConnectionAtIndex(index) {
                    if let match = [t1, t2].first(where: { $0 === initiatingTerminal }) as? TerminalView, match.isInput == true {
                        initiatingTerminal = (t1 === initiatingTerminal) ? t2 : t1
                        let origin = CGPoint(x: initiatingTerminal?.frame.midX ?? 0, y: initiatingTerminal?.frame.midY ?? 0)
                        initialMousePoint = convert(origin, from: initiatingTerminal?.superview)
                        delegate?.didDisconnect(t1, from: t2)
                    }
                }
            }

            drawLink(from: initialMousePoint, to: lastMousePoint)

            initiatingTerminal?.isConnected = true
        }

        // Selection drawing
        if isSelectingWithRectangle {
            drawSelection(from: initialMousePoint, to: lastMousePoint)
        }

        // Permanent lines drawing
        terminalViews.filter({ $0 !== initiatingTerminal }).forEach({ $0.isConnected = false })
        if let datasource = datasource {
            for index in 0..<datasource.numberOfConnections() {
                let (t1, t2) = datasource.terminalViewsForConnectionAtIndex(index)
                let a = convert(t1.frame, from: t1.superview)
                let b = convert(t2.frame, from: t2.superview)
                drawLink(from: CGPoint(x: a.midX, y: a.midY), to: CGPoint(x: b.midX, y: b.midY))
                t1.isConnected = true
                t2.isConnected = true
            }
        }

    }

}

// MARK: - Event Handling
extension BoardView {

    fileprivate func terminalForPoint(_ point: CGPoint?) -> TerminalView? {
        guard let point = point else { return nil }
        return terminalViews.first(where: { convert($0.frame, from: $0.superview).contains(point) })
    }

    public override func rightMouseDown(with event: NSEvent) {
        // Show a contextual menu
//        var theMenu = NSMenu(title: "Contextual Menu")
//        theMenu.insertItem(withTitle: "Beep", action: nil, keyEquivalent: "", at: 0)
//        theMenu.insertItem(withTitle: "Honk", action: nil, keyEquivalent: "", at: 1)
//        NSMenu.popUpContextMenu(theMenu, with: event, for: self)
    }

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        initialMousePoint = event.locationConvertedFor(self)
        lastMousePoint    = initialMousePoint

        // If we're on top of a connectionView start drawing a line
        if terminalForPoint(initialMousePoint) != nil {
            isDrawingLine = true
        }

        if !isDrawingLine {
            isSelectingWithRectangle = true
        }
    }

    public override func mouseDragged(with event: NSEvent) {
        lastMousePoint = event.locationConvertedFor(self)
        if initialMousePoint == nil {
            initialMousePoint = lastMousePoint
        }
        needsDisplay = true
    }

    public override func mouseUp(with event: NSEvent) {
        isDrawingLine            = false
        isSelectingWithRectangle = false
        needsDisplay             = true

        let terminal1 = terminalForPoint(initialMousePoint)
        let terminal2 = terminalForPoint(lastMousePoint)

        if let t1 = terminal1, let t2 = terminal2, t1.isInput != t2.isInput {
            let input = t1.isInput ? t1 : t2
            let output = !t1.isInput ? t1 : t2
            if delegate?.shouldConnect(input, to: output) == true {
                delegate?.didConnect(input, to: output)
            }
        }
    }

    func drawLink(from startPoint: NSPoint, to endPoint: NSPoint) {
        let color = ThemeColor.line
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
        let fillColor   = ThemeColor.selection.withAlphaComponent(0.1)
        let strokeColor = ThemeColor.selection
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
