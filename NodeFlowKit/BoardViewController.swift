//
//  BoardController.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 17/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class CenteredClipView: NSClipView {
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        if let containerView = self.documentView {
            if (rect.size.width > containerView.frame.size.width) {
                rect.origin.x = (containerView.frame.width - rect.width) / 2
            }
            if (rect.size.height > containerView.frame.size.height) {
                rect.origin.y = (containerView.frame.height - rect.height) / 2
            }
        }
        return rect
    }
}

class FlippedScrollView: NSScrollView {
    override var isFlipped: Bool { return true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        contentView = CenteredClipView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func scrollWheel(with event: NSEvent) {
        guard event.modifierFlags.contains(.option) else { super.scrollWheel(with: event); return }
        let pt = documentView?.convert(event.locationInWindow, from: nil)
        //let center = NSPoint(x: documentView!.bounds.midX, y: documentView!.bounds.midY)
        var by: CGFloat = event.scrollingDeltaY * 0.001 // The smallest pinch-zoom amount seems to be about 0.002, but that was a bit too coarse.
        if !event.hasPreciseScrollingDeltas {
            by *= verticalLineScroll
        }
        setMagnification(magnification + by, centeredAt: pt ?? .zero)
    }
}

extension NSScrollView {
    func scrollToCenter() {
        guard let docView = documentView else { return }
        let center = CGPoint(
            x: docView.bounds.midX - contentView.frame.width / 2,
            y: docView.bounds.midY - (docView.isFlipped ? 1 : -1) * contentView.frame.height / 2
        )
        docView.scroll(center)
    }
}

open class BoardViewController: NSViewController, BoardViewDelegate, BoardViewRenderingDatasource {

    fileprivate var scrollView = FlippedScrollView(frame: .zero)
    public var boardView = BoardView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))

    public var graph: GraphRepresenter! {
        didSet {
            boardView.graph = graph
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller   = true
        scrollView.allowsMagnification   = true

        boardView.translatesAutoresizingMaskIntoConstraints = false

        boardView.delegate = self
        boardView.renderingDatasource = self

        scrollView.documentView = boardView
        view.addSubview(scrollView)
    }

    override open func viewDidLayout() {
        super.viewDidLayout()
        scrollView.frame = view.bounds
    }

    open override func viewWillAppear() {
        super.viewWillAppear()
        scrollView.scrollToCenter()
    }

    @objc open func shouldConnect(_ terminal: TerminalView, to otherTerminal: TerminalView) -> Bool {
        return terminal.isInput != otherTerminal.isInput
            && arePropertiesCompatible(terminal.property, otherTerminal.property)
            && terminal.property.node !== otherTerminal.property.node
    }

    @objc open func didConnect(_ inputTerminal: TerminalView, to outputTerminal: TerminalView) {
        if let existingConnection = graph.connections.first(where: { $0.input === inputTerminal.property }),
            let input = boardView.terminalViewForProperty(existingConnection.input),
            let output = boardView.terminalViewForProperty(existingConnection.output) {
            didDisconnect(input, from: output)
        }
        graph.createConnection(inputTerminal: inputTerminal, outputTerminal: outputTerminal)
    }

    @objc open func didDisconnect(_ inputTerminal: TerminalView, from outputTerminal: TerminalView) {
        guard let connection = graph.connections.first(where: { $0.input === inputTerminal.property && $0.output === outputTerminal.property }) else {
            print("Connection not found")
            return
        }
        graph.removeConnection(connection)
    }

    public func addNode(_ node: NodeRepresenter, at point: CGPoint) {
        graph.addNode(node)
        boardView.addNode(node, at: point)
    }

    @objc public func removeNode(_ node: AnyObject?) {
        guard let node = graph.nodes.first(where: { $0 === node }) else { return }
        graph.removeNode(node)
        // Removes itself from the boardview
        boardView.needsDisplay = true // To remove the connection link
    }

    open func allowedDraggedTypes() -> [NSPasteboard.PasteboardType] {
        return []
    }

    open func didDropWithInfo(_ info: NSDraggingInfo) {}

    //MARK:- Rendering Datasource
    open func rightAccessoryViewForNode(_ node: NodeRepresenter) -> NSView? {
        return nil
    }

    open func controlRowsForNode(_ node: NodeRepresenter) -> [NodeRowRepresentable] {
        return []
    }

    open func controlViewForProperty(_ property: NodeProperty) -> NSView {
        return NSView()
    }

    open func topAccessoryViewForProperty(_ property: NodeProperty) -> NSView? {
        return nil
    }

    open func bottomAccessoryViewForProperty(_ property: NodeProperty) -> NSView? {
        return nil
    }

}
