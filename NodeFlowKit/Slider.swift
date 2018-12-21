//
//  Slider.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 21/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

class Slider: NSControl, NSTextFieldDelegate {

    var name: String = "" {
        didSet {
            nameField.stringValue = name
        }
    }

    let nameField: NSTextField = {
        let field = NSTextField(labelWithString: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = NSFont.systemFont(ofSize: 10)
        return field
    }()

    let textField: NSTextField = {
        let field = NSTextField(string: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.drawsBackground = false
        field.isBordered = false
        field.alignment = NSTextAlignment.right
        field.font = NSFont.systemFont(ofSize: 10)

        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 3
        f.minimumFractionDigits = 3
        f.locale = Locale(identifier: "en_US")
        field.formatter = f
        return field
    }()

    let color = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)

    fileprivate var value: Double = 0

    override var doubleValue: Double {
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
        addSubview(textField)
        addSubview(nameField)

        let stackView = NSStackView(views: [nameField, textField])
        stackView.distribution = .equalSpacing
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
        textField.isEditable = true
        textField.becomeFirstResponder()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            // Do something against ENTER key
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
            window?.makeFirstResponder(nil)
            return true
        }

        // return true if the action was handled; otherwise false
        return false
    }

    var bgPath: NSBezierPath {
        let lineWidth: CGFloat = 1
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2), xRadius: 6, yRadius: 6)
        path.lineWidth = lineWidth
        return path
    }

    func drawBackground() {
        color.withAlphaComponent(0.4).setStroke()
        bgPath.stroke()
    }

    func drawFillTrack() {
        let clipPath = bgPath
        let path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: max(10, min(CGFloat(doubleValue), bounds.width)), height: bounds.height))
        color.withAlphaComponent(0.4).setFill()
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
        doubleValue = initialValue + Double(delta)
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 100, height: 20)
    }

}
