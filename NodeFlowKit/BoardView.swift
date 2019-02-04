//
//  BoardView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class ColorGridView: NSView {
    static let color = NSColor(patternImage: GridView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).image())
    override func draw(_ dirtyRect: NSRect) {
        let theContext = NSGraphicsContext.current
        theContext?.saveGraphicsState()
        ThemeColor.background.setFill()
        dirtyRect.fill()
        theContext?.patternPhase = NSMakePoint(0, 100)
        ColorGridView.color.set()
        dirtyRect.fill()
        theContext?.restoreGraphicsState()
    }
}

/*--------------------------------------------------------------------------------*/

class LinkLayer: CAShapeLayer {
    var terminals: (a: TerminalView, b: TerminalView)? = nil

    var terminalList: [TerminalView] {
        guard let terminals = terminals else { return [] }
        return [terminals.a, terminals.b]
    }

    convenience init(terminals: (a: TerminalView, b: TerminalView)) {
        self.init()
        self.terminals = terminals
    }

    override init() {
        super.init()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        lineWidth   = 5
        lineCap     = .round
        strokeColor = ThemeColor.line.cgColor
        fillColor   = NSColor.clear.cgColor
        zPosition   = -1 // Behind nodeviews
        shadowColor = NSColor.black.cgColor
        shadowRadius = 4
        shadowOpacity = 0.2
    }
}

public class BoardView: NSView {

    // Selection variables
    fileprivate var startPoint: NSPoint!
    fileprivate var isSelectingWithRectangle = false

    weak var datasource: BoardViewDatasource?
    public weak var delegate: BoardViewDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            registerForDraggedTypes(delegate.allowedDraggedTypes())
        }
    }

    var nodeViews: [NodeView] {
        return subviews.compactMap({ $0 as? NodeView })
    }

    var terminalViews: [TerminalView] {
        return nodeViews.flatMap({ $0.terminals })
    }

    fileprivate let gridView = ColorGridView()

    public override var isFlipped: Bool { return true }
    public override var acceptsFirstResponder: Bool { return true }
    public override var wantsUpdateLayer: Bool { return true }
    public override var isOpaque: Bool { return false }

    // Links
    fileprivate var initialMousePoint: CGPoint!
    fileprivate var lastMousePoint: CGPoint!
    fileprivate var isDrawingLine: Bool = false

    fileprivate let activeLinkLayer = LinkLayer()
    fileprivate var linkLayers = [LinkLayer]()
    fileprivate let activeSelectionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.fillColor = ThemeColor.selection.withAlphaComponent(0.1).cgColor
        layer.strokeColor = ThemeColor.selection.cgColor
        return layer
    }()

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
        gridView.frame = self.bounds
        gridView.wantsLayer = true
        gridView.layer?.zPosition = -2 // Behind everything
        activeSelectionLayer.zPosition = 1 // Above nodeviews
        layer?.addSublayer(activeLinkLayer)
        layer?.addSublayer(activeSelectionLayer)
        addSubview(gridView)
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

    @objc public func addNodeAtIndex(_ index: Int, at point: CGPoint) {
        guard let nodeView = datasource?.nodeViewForIndex(index) else { return }
        addSubview(nodeView)
        nodeView.setFrameOrigin(convert(point, from: nil))
    }

    func addLinkLayer(_ link: LinkLayer) {
        guard !linkLayers.contains(link) else { return }
        linkLayers.append(link)
        layer?.addSublayer(link)
    }

    func removeLinkLayer(_ link: LinkLayer) {
        linkLayers.removeAll(where: { $0 === link })
        link.removeFromSuperlayer()
    }

    public override func updateLayer() {

        // Make sure that interactive drawing layers are handled from a central exit point
        defer {
            if !isDrawingLine {
                activeLinkLayer.path = nil
            }
            if !isSelectingWithRectangle {
                activeSelectionLayer.path = nil
            }
        }

        // Interactive line drawing
        var initiatingTerminal: TerminalView?
        if isDrawingLine {

            initiatingTerminal = terminalForPoint(initialMousePoint)

            if let initiating = initiatingTerminal,
                let existing = linkLayers.lazy.first(where: { $0.terminalList.contains(initiating) }),
                let t1 = existing.terminals?.a,
                let t2 = existing.terminals?.b,
                initiating.isInput {
                    initiatingTerminal = (t1 === initiatingTerminal) ? t2 : t1
                    let origin = CGPoint(x: initiatingTerminal?.frame.midX ?? 0, y: initiatingTerminal?.frame.midY ?? 0)
                    initialMousePoint = convert(origin, from: initiatingTerminal?.superview)
                    delegate?.didDisconnect(t1, from: t2)
                    removeLinkLayer(existing)
            }

            var initiatingPoint: CGPoint! = initialMousePoint
            if let t1 = initiatingTerminal {
                let localFrame = convert(t1.frame, from: t1.superview)
                initiatingPoint = CGPoint(x: localFrame.midX, y: localFrame.midY)

                #warning("Refactor")
                for nodeView in nodeViews {
                    for property in nodeView.node.inputs {
                        property.controlView.superview?.alphaValue = property.isCompatibleWith(t1.property) ? 1 : 0.3
                    }
                }
            }

            activeLinkLayer.path = linkPathBetween(point: initiatingPoint, and: lastMousePoint).cgPath
            initiatingTerminal?.isConnected = true
        } else {
            #warning("Refactor")
            for nodeView in nodeViews {
                for property in nodeView.node.inputs {
                    property.controlView.superview?.alphaValue = 1.0
                }
            }
        }

        // Selection drawing
        if isSelectingWithRectangle {
            activeSelectionLayer.path = selectionPathBetween(point: initialMousePoint, and: lastMousePoint).cgPath
            for nodeView in nodeViews {
                nodeView.isSelected = rectBetween(point: initialMousePoint, and: lastMousePoint).intersects(nodeView.frame)
            }
        }

        // Permanent lines drawing
        terminalViews.filter({ $0 !== initiatingTerminal }).forEach({ $0.isConnected = false })
        for link in linkLayers {
            guard let t1 = link.terminals?.a, let t2 = link.terminals?.b else { continue }
            let a = convert(t1.frame, from: t1.superview)
            let b = convert(t2.frame, from: t2.superview)
            link.path = linkPathBetween(point: CGPoint(x: a.midX, y: a.midY), and: CGPoint(x: b.midX, y: b.midY)).cgPath
            t1.isConnected = true
            t2.isConnected = true
        }
    }

}

/*--------------------------------------------------------------------------------*/

// MARK: - Drag & Drop
extension BoardView {
    override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .generic
    }

    override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        delegate?.didDropWithInfo(sender)
        return true
    }
}

/*--------------------------------------------------------------------------------*/

// MARK: - Event Handling
extension BoardView {

    fileprivate func terminalForPoint(_ point: CGPoint?) -> TerminalView? {
        guard let point = point else { return nil }
        return terminalViews.first(where: { convert($0.frame, from: $0.superview).contains(point) })
    }

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)

        initialMousePoint = event.locationConvertedFor(self)
        lastMousePoint    = initialMousePoint

        // If we're on top of a connectionView start drawing a line
        if terminalForPoint(initialMousePoint) != nil {
            isDrawingLine = true
        }

        nodeViews.forEach({ $0.isSelected = false })
    }

    public override func mouseDragged(with event: NSEvent) {
        lastMousePoint = event.locationConvertedFor(self)

        if initialMousePoint == nil {
            initialMousePoint = lastMousePoint
        }

        if !isDrawingLine {
            isSelectingWithRectangle = true
        }

        needsDisplay = true
    }

    public override func mouseUp(with event: NSEvent) {
        isDrawingLine            = false
        isSelectingWithRectangle = false

        let terminal1 = terminalForPoint(initialMousePoint)
        let terminal2 = terminalForPoint(lastMousePoint)

        if let t1 = terminal1, let t2 = terminal2, t1.isInput != t2.isInput {
            let input = t1.isInput ? t1 : t2
            let output = !t1.isInput ? t1 : t2
            if delegate?.shouldConnect(input, to: output) == true {
                if input.isConnected, let existing = linkLayers.first(where: { $0.terminalList.contains(input) }) {
                    removeLinkLayer(existing)
                }
                delegate?.didConnect(input, to: output)
                addLinkLayer(LinkLayer(terminals: (input, output)))
            }
        }

        needsDisplay = true
    }

    // Middle button scrolling
    public override func otherMouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        initialMousePoint = event.locationInWindow
        initialMousePoint.x += visibleRect.origin.x
        initialMousePoint.y -= visibleRect.origin.y
        lastMousePoint    = initialMousePoint

        if event.clickCount == 2 {
            nextResponder?.tryToPerform(#selector(setter: NSScrollView.magnification), with: NSNumber(value: 1.0))
        }
    }

    public override func otherMouseDragged(with event: NSEvent) {
        lastMousePoint = event.locationInWindow
        if initialMousePoint == nil {
            initialMousePoint = lastMousePoint
        }
        let deltaX = initialMousePoint.x - lastMousePoint.x
        let deltaY = initialMousePoint.y - lastMousePoint.y
        scroll(CGPoint(x: deltaX, y: deltaY * -1))
    }

    func linkPathBetween(point p1: NSPoint, and p2: NSPoint) -> NSBezierPath {
        // Shadow vars & Swap depending on direction
        var inputPoint = p1
        var outputPoint = p2

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

        if ProcessInfo.processInfo.environment["debugDraw"] != nil {
            drawControlPoints([p1, p2], ofPoints: [inputPoint, outputPoint])
        }
        
        return path
    }

    func selectionPathBetween(point p1: NSPoint, and p2: NSPoint) -> NSBezierPath {
        let rect = rectBetween(point: p1, and: p2)
        return NSBezierPath(rect: rect)
    }

    @objc func moveSelectedNodesBy(_ value: NSValue) {
        let delta = value.pointValue
        for nodeView in nodeViews.filter({ $0.isSelected }) {
            let newX = nodeView.frame.origin.x + delta.x
            let newY = nodeView.frame.origin.y + delta.y
            nodeView.setFrameOrigin(CGPoint(x: newX, y: newY))
        }
    }
}

/*--------------------------------------------------------------------------------*/

// MARK: - DEBUG Visualizations
extension BoardView {
    func drawControlPoints(_ controlPoints: [NSPoint], ofPoints points: [NSPoint]) {
        let context = NSGraphicsContext.current
        context?.saveGraphicsState()

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

        context?.restoreGraphicsState()
    }
}
