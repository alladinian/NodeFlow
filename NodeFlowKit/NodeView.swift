//
//  NFView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class NodeView: NSView {

    private(set) var isSelected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    weak var node: Node!
    var connections = [ConnectionView]()

    init(node: Node) {
        super.init(frame: .zero)
        self.node = node
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func commonInit() {

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(stackView)

        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ]

        NSLayoutConstraint.activate(stackConstraints)

        wantsLayer          = true
        layer?.cornerRadius = kCornerRadius
        layer?.borderWidth  = 2

        setupHeader()
        setupShadow()

        title = "Node"
        titleLabel.heightAnchor.constraint(equalToConstant: kHeaderHeight).isActive = true
        stackView.addArrangedSubview(titleLabel)

        setupOutputs()
        setupInputs()

        needsDisplay = true
    }

    public override func layout() {
        super.layout()
        headerLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: kHeaderHeight)
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

    fileprivate func setupOutputs() {
        guard !node.outputs.isEmpty else { return }
        for output in node.outputs {
            let row = connectionRowForProperty(output, isInput: false)
            stackView.addArrangedSubview(row)
            constraintHorizontalEdgesOf(row, to: stackView)
        }
        stackView.setCustomSpacing(20, after: stackView.arrangedSubviews.last!)
    }

    fileprivate func setupInputs() {
        for input in node.inputs {
            let row = connectionRowForProperty(input, isInput: true)
            stackView.addArrangedSubview(row)
            constraintHorizontalEdgesOf(row, to: stackView)
        }
    }

    fileprivate func connectionRowForProperty(_ property: Property, isInput: Bool) -> NSView {
        let connection  = ConnectionView(property: property)
        connection.isInput = isInput
        connections.append(connection)

        let slider  = Slider(frame: .zero)
        slider.name = property.name

        let label       = NSTextField(labelWithString: property.name)
        label.font      = NSFont.systemFont(ofSize: 14)
        label.textColor = NSColor.textColor
        label.alignment = isInput ? .left : .right

        let horizontalStack = NSStackView(views: isInput ? [connection, slider] : [slider, connection])
        horizontalStack.distribution = .fill
        horizontalStack.spacing      = 8

        return horizontalStack
    }

    fileprivate func constraintHorizontalEdgesOf(_ a: NSView, to b: NSView) {
        NSLayoutConstraint.activate([
            a.leadingAnchor.constraint(equalTo: b.leadingAnchor),
            a.trailingAnchor.constraint(equalTo: b.trailingAnchor)
        ])
    }

    public override func updateLayer() {
        super.updateLayer()
        headerColor        = NSColor.textBackgroundColor
        color              = NSColor.underPageBackgroundColor.withAlphaComponent(0.95)
        layer?.borderColor = isSelected ? NSColor.selectedControlColor.cgColor : NSColor.clear.cgColor
    }
}

extension NodeView {

    var isMouseOverConnection: Bool {
        return connections.lazy.first(where: { $0.isHighlighted }) != nil
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
        lastMousePoint = NSEvent.mouseLocation
        window?.makeFirstResponder(self)
        discardCursorRects()
        NSCursor.closedHand.push()
    }

    override public func mouseDragged(with event: NSEvent) {
        guard lastMousePoint != nil else {
            return
        }
        let newPoint = NSEvent.mouseLocation
        var origin   = frame.origin
        origin.x += newPoint.x - lastMousePoint.x
        origin.y += (newPoint.y - lastMousePoint.y) * (isFlipped ? -1 : 1)
        setFrameOrigin(origin)
        lastMousePoint = newPoint

        superview?.needsDisplay = true
    }

    override public func mouseUp(with event: NSEvent) {
        lastMousePoint = nil
        NSCursor.pop()
        window?.invalidateCursorRects(for: self)
    }

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(headerLayer.bounds, cursor: NSCursor.openHand)
    }

}
