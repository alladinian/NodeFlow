//
//  Slider.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 21/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

@IBDesignable
class Slider: NSControl, NSTextFieldDelegate {

    @IBInspectable var name: String = "" {
        didSet {
            nameField.stringValue = name
        }
    }

    @IBInspectable var minimum: Double = 0
    @IBInspectable var maximum: Double = 1

    let nameField: NSTextField = {
        let field = NSTextField(labelWithString: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = NSFont.boldSystemFont(ofSize: 10)
        return field
    }()

    let textField: NSTextField = {
        let field = NSTextField(string: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.drawsBackground = false
        field.isBordered = false
        field.alignment = NSTextAlignment.right
        field.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)

        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 3
        f.minimumFractionDigits = 3
        f.locale = Locale(identifier: "en_US")
        field.formatter = f
        return field
    }()

    @IBInspectable var color: NSColor = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1).withAlphaComponent(0.4)
    let inactiveColor: NSColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2470588235)
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            needsDisplay = true
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }

    fileprivate var value: Double = 0

    @IBInspectable override var doubleValue: Double {
        set {
            value = newValue
            needsDisplay = true
            textField.doubleValue = newValue
        }
        get {
            return value
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    func commonInit() {
        isContinuous = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(textField)
        addSubview(nameField)

        let stackView = NSStackView(views: [nameField, NSView(), textField])
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        textField.isEditable = false
        textField.isSelectable = false
        textField.focusRingType = .none
        textField.delegate = self
        textField.doubleValue = doubleValue

        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.numberOfClicksRequired = 2
        gesture.target = self
        gesture.action = #selector(editValue)
        addGestureRecognizer(gesture)
    }

    @objc func editValue() {
        isEditing = true
        textField.isEditable = true
        textField.becomeFirstResponder()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            // Do something against ENTER key
            doubleValue = textField.doubleValue.clamped(to: (minimum...maximum))
            textField.isEditable = false
            window?.makeFirstResponder(nil)
            return true
        } else if (commandSelector == #selector(NSResponder.deleteForward(_:))) {
            // Do something against DELETE key
            return true
        } else if (commandSelector == #selector(NSResponder.deleteBackward(_:))) {
            // Do something against BACKSPACE key
            return true
        } else if (commandSelector == #selector(NSResponder.insertTab(_:))) {
            // Do something against TAB key
            return true
        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            // Do something against ESCAPE key
            textField.isEditable = false
            textField.doubleValue = doubleValue
            window?.makeFirstResponder(nil)
            return true
        }

        // return true if the action was handled; otherwise false
        return false
    }

    var isEditing = false {
        didSet {
            needsDisplay = true
        }
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        textField.doubleValue = doubleValue
        isEditing = false
    }

    func controlTextDidChange(_ obj: Notification) {

    }

    var bgPath: NSBezierPath {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2), xRadius: cornerRadius, yRadius: cornerRadius)
        path.lineWidth = borderWidth
        return path
    }

    func drawBackground() {
        (isEditing ? inactiveColor : color).setStroke()
        bgPath.stroke()
    }

    func drawFillTrack() {
        let clipPath = bgPath
        let path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: CGFloat(doubleValue / maximum * Double(bounds.width)), height: bounds.height))
        (isEditing ? inactiveColor : color).setFill()
        clipPath.setClip()
        path.fill()
        path.addClip()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBackground()
        drawFillTrack()
    }

    fileprivate var initialValue: Double = 0
    fileprivate var initialMouseLocation: NSPoint = .zero
    fileprivate var lastMouseLocation: NSPoint = .zero
    fileprivate var isDragging: Bool = false

    override func mouseDown(with event: NSEvent) {
        initialMouseLocation = NSEvent.mouseLocation
        initialValue = doubleValue
    }

    override func mouseDragged(with event: NSEvent) {
        isDragging = true
        lastMouseLocation = NSEvent.mouseLocation
        let delta = lastMouseLocation.x - initialMouseLocation.x
        let percentage = Double(delta) / Double(bounds.width) * maximum
        doubleValue = (initialValue + percentage).clamped(to: (minimum...maximum))
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 150, height: 24)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Slider {
    override func prepareForInterfaceBuilder() {

    }
}
