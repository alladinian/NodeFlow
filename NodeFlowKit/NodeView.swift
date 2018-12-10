//
//  NFView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

public class NodeView: NSView {

    private(set) var isSelected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        title = "Node"
        setupOutputs()
        setupInputs()
        needsDisplay = true
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

    public var inputs: [Input]   = []
    public var outputs: [Output] = []

    // Private
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var stackView: NSStackView!

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
        wantsLayer = true
        layer?.cornerRadius = kCornerRadius
        layer?.borderWidth = 2

        setupHeader()
        setupShadow()
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
        guard !outputs.isEmpty else { return }
        for output in outputs {
            let row = connectionRowWithTitle(output.name, isInput: false)
            stackView.addArrangedSubview(row)
            constraintHorizontalEdgesOf(row, to: stackView)
        }
        stackView.setCustomSpacing(20, after: stackView.arrangedSubviews.last!)
    }

    fileprivate func setupInputs() {
        for input in inputs {
            let row = connectionRowWithTitle(input.name, isInput: true)
            stackView.addArrangedSubview(row)
            constraintHorizontalEdgesOf(row, to: stackView)
        }
    }

    fileprivate func connectionRowWithTitle(_ title: String, isInput: Bool) -> NSView {
        let connection  = ConnectionView()
        connection.isInput = isInput
        connections.append(connection)

        let label       = NSTextField(labelWithString: title)
        label.font      = NSFont.systemFont(ofSize: 14)
        label.textColor = NSColor.textColor
        label.alignment = isInput ? .left : .right

        let horizontalStack = NSStackView(views: isInput ? [connection, label] : [label, connection])
        horizontalStack.distribution = .fill
        horizontalStack.spacing      = 8

        return horizontalStack
    }

    fileprivate func constraintHorizontalEdgesOf(_ a: NSView, to b: NSView) {
        a.leadingAnchor.constraint(equalTo: b.leadingAnchor).isActive = true
        a.trailingAnchor.constraint(equalTo: b.trailingAnchor).isActive = true
    }

    public override func updateLayer() {
        super.updateLayer()
        headerColor        = NSColor.textBackgroundColor
        color              = NSColor.underPageBackgroundColor.withAlphaComponent(0.85)
        layer?.borderColor = isSelected ? NSColor.selectedControlColor.cgColor : NSColor.clear.cgColor
    }

    var connections = [ConnectionView]()
}
