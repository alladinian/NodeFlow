//
//  NFView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class NodeView: NSView {

    // Single requirement
    var node: NodeRepresenter!

    var terminals = [TerminalView]()

    init(node: NodeRepresenter) {
        super.init(frame: .zero)
        self.node = node
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var isSelected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public var title: String! {
        didSet {
            titleLabel.stringValue = title
        }
    }

    public var color: NSColor! {
        didSet {
            layer?.backgroundColor = color.cgColor
        }
    }

    public var headerColor: NSColor! {
        didSet {
            headerLayer.backgroundColor = headerColor.cgColor
        }
    }

    override var frame: NSRect {
        didSet {
            node.origin = frame.origin
        }
    }

    public var rightAccessoryView: NSView? = nil

    // Private
    fileprivate let titleLabel = NSTextField(labelWithString: "")
    fileprivate let stackView: NSStackView = {
        let stackView = NSStackView(views: [])
        stackView.orientation = .vertical
        return stackView
    }()

    fileprivate let headerLayer = CALayer()
    fileprivate var lastMousePoint: CGPoint!

    public override var isFlipped: Bool { return true }
    public override var wantsUpdateLayer: Bool { return true }

    fileprivate let kCornerRadius: CGFloat       = 12
    fileprivate let kHeaderHeight: CGFloat       = 24
    fileprivate let kMinNodeWidth: CGFloat       = 100
    fileprivate let kMinNodeHeight: CGFloat      = 100
    fileprivate let kRowHeight: CGFloat          = 24
    fileprivate let kTitleMargin: CGFloat        = 10
    fileprivate let kTitleVerticalInset: CGFloat = 4

    fileprivate var closeButton: NSButton!

    func commonInit() {

        if wantsUpdateLayer {
            layerContentsRedrawPolicy = .onSetNeedsDisplay
        }

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(stackView)

        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ]

        NSLayoutConstraint.activate(stackConstraints)

        wantsLayer          = true
        layer?.cornerRadius = kCornerRadius
        layer?.borderWidth  = 2

        setupCloseButton()
        setupHeader()
        setupShadow()

        title = node.name
        rightAccessoryView = node.rightAccessoryView

        titleLabel.heightAnchor.constraint(equalToConstant: kHeaderHeight).isActive = true

        let headerStackView = NSStackView()
        headerStackView.orientation  = .horizontal
        headerStackView.distribution = .fill
        headerStackView.alignment    = .firstBaseline
        //headerStackView.addArrangedSubview(closeButton)
        headerStackView.addArrangedSubview(titleLabel)

        if let rightView = rightAccessoryView {
            headerStackView.addArrangedSubview(rightView)
        }

        stackView.addArrangedSubview(headerStackView)

        constraintHorizontalEdgesOf(headerStackView, to: stackView)

        setupRows()

        needsDisplay = true
    }

    public override func layout() {
        super.layout()
        headerLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: kHeaderHeight)
    }

    func setupCloseButton() {
        closeButton = NSButton(image: NSImage(named: NSImage.statusUnavailableName)!, target: self, action: #selector(close))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        //closeButton.isBordered = false
        closeButton.bezelStyle = .smallSquare
        //closeButton.heightAnchor.constraint(equalToConstant: kHeaderHeight).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1).isActive = true
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Remove", action: #selector(close), keyEquivalent: "")
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    @objc func close() {
        nextResponder?.tryToPerform(#selector(BoardViewController.removeNode), with: node)
        removeFromSuperview()
    }

    func setupHeader() {
        headerLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerLayer.cornerRadius  = kCornerRadius
        layer?.addSublayer(headerLayer)
    }

    fileprivate func setupShadow() {
        let shadow              = NSShadow()
        shadow.shadowOffset     = NSSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 10
        self.shadow             = shadow
    }

    fileprivate func setupRows() {
        for row in node.controlRows {
            if let view = row as? NSView {
                stackView.addArrangedSubview(view)
                constraintHorizontalEdgesOf(view, to: stackView)
            } else if let property = row as? NodeProperty {
                let control = connectionRowForProperty(property)
                stackView.addArrangedSubview(control)
                constraintHorizontalEdgesOf(control, to: stackView)
            }
        }
    }

    fileprivate func connectionRowForProperty(_ property: NodeProperty) -> NSView {
        let terminal = TerminalView(property: property)
        let isInput = property.isInput
        terminal.isInput = isInput
        terminals.append(terminal)

        let control = property.controlView

        let horizontalStack = NSStackView(views: isInput ? [terminal, control] : [control, terminal])
        horizontalStack.distribution = .fill
        horizontalStack.spacing      = 8

        let verticalStack = NSStackView()
        verticalStack.orientation = .vertical
        verticalStack.distribution = .fill

        if let accessory = property.topAccessoryView {
            verticalStack.addArrangedSubview(accessory)
        }

        verticalStack.addArrangedSubview(horizontalStack)

        constraintHorizontalEdgesOf(horizontalStack, to: verticalStack)

        if let accessory = property.bottomAccessoryView {
            verticalStack.addArrangedSubview(accessory)
        }

        return verticalStack
    }

    fileprivate func constraintHorizontalEdgesOf(_ a: NSView, to b: NSView) {
        NSLayoutConstraint.activate([
            a.leadingAnchor.constraint(equalTo: b.leadingAnchor),
            a.trailingAnchor.constraint(equalTo: b.trailingAnchor)
        ])
    }

    public override func updateLayer() {
        headerColor        = ThemeColor.nodeHeader
        color              = ThemeColor.nodeBackground.withAlphaComponent(0.95)
        layer?.borderColor = isSelected ? ThemeColor.nodeSelection.cgColor : NSColor.clear.cgColor
    }
}

extension NodeView {

    var isMouseOverConnection: Bool {
        return terminals.lazy.first(where: { $0.isHighlighted }) != nil
    }

    public override func becomeFirstResponder() -> Bool {
        isSelected = true
        return true
    }

    public override func resignFirstResponder() -> Bool {
        isSelected = false
        return true
    }

    public override var acceptsFirstResponder: Bool {
        return true
    }

    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        if isMouseOverConnection {
            return nil
        }
        return super.hitTest(point)
    }

    override public func mouseDown(with event: NSEvent) {
        lastMousePoint = event.locationInWindow
        window?.makeFirstResponder(self)
        /*
        discardCursorRects()
        NSCursor.closedHand.push()
        */
    }

    override public func mouseDragged(with event: NSEvent) {
        guard lastMousePoint != nil else {
            return
        }

        let newPoint = event.locationInWindow
        var origin   = frame.origin
        let deltaX = newPoint.x - lastMousePoint.x
        let deltaY = (newPoint.y - lastMousePoint.y) * (isFlipped ? -1 : 1)
        origin.x += deltaX
        origin.y += deltaY

        // Move the view
        //setFrameOrigin(origin)
        (superview as? BoardView)?.moveSelectedNodesBy(CGPoint(x: deltaX, y: deltaY))

        // Redraw superview to update any connection lines
        superview?.needsDisplay = true

        lastMousePoint = newPoint
    }

    override public func mouseUp(with event: NSEvent) {
        lastMousePoint = nil
        /*
        NSCursor.pop()
        window?.invalidateCursorRects(for: self)
        */
    }

    /*
    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(headerLayer.bounds, cursor: NSCursor.openHand)
        addCursorRect(closeButton.bounds, cursor: NSCursor.arrow)
    }
    */

}
