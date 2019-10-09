//
//  GridView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 24/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa

/*--------------------------------------------------------------------------------*/

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

class GridView: NSView {
    var gridSpacing = 10
    override var isFlipped: Bool {
        return true
    }
    static let tileBounds = NSRect(x: 0, y: 0, width: 100, height: 100)
    static var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)
    static let pattern = CGPattern(info: nil,
                                   bounds: tileBounds,
                                   matrix: .identity,
                                   xStep: tileBounds.width,
                                   yStep: tileBounds.height,
                                   tiling: .constantSpacing,
                                   isColored: true,
                                   callbacks: &callbacks)
    static let patternSpace = CGColorSpace(patternBaseSpace: nil)
    static let drawPattern: CGPatternDrawPatternCallback = { (info, context) in

        func colorForStep(_ step: Int) -> NSColor {
            let stops: [(n: Int, a: CGFloat)] = [(10, 0.3), (5, 0.2)]
            let alpha: CGFloat = stops.lazy.first(where : { step.isMultiple(of: $0.n) })?.a ?? 0.1
            return ThemeColor.grid.withAlphaComponent(alpha)
        }

        func pointsForStep(_ step: Int, isVertical: Bool) -> (start: CGPoint, end: CGPoint) {
            let position = CGFloat(step) * 10 - 0.5
            let start    = CGPoint(x: isVertical ? 0 : position, y: isVertical ? position : 0)
            let end      = CGPoint(x: isVertical ? tileBounds.width : position, y: isVertical ? position : tileBounds.height)
            return (start, end)
        }

        // Vertical Steps ↓
        for step in 1...10 {
            context.setStrokeColor(colorForStep(step).cgColor)
            let points = pointsForStep(step, isVertical: true)
            context.move(to: points.start)
            context.addLine(to: points.end)
            context.strokePath()
        }

        // Horizontal Steps →
        for step in 1...10 {
            context.setStrokeColor(colorForStep(step).cgColor)
            let points = pointsForStep(step, isVertical: false)
            context.move(to: points.start)
            context.addLine(to: points.end)
            context.strokePath()
        }
    }

    fileprivate func drawGridPattern(context: CGContext) {
        context.saveGState()
        context.setFillColorSpace(GridView.patternSpace!)
        var alpha: CGFloat = 1.0
        context.setFillPattern(GridView.pattern!, colorComponents: &alpha)
        context.fill(bounds)
        context.restoreGState()
    }

    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current!.cgContext
        drawGridPattern(context: context)
        //drawGrid()
    }

    func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
}

// MARK: - Grid drawing (non pattern)
extension GridView {

    fileprivate var verticalSteps: Int {
        return Int(bounds.size.height) / gridSpacing
    }

    fileprivate var horizontalSteps: Int {
        return Int(bounds.size.width) / gridSpacing
    }

    fileprivate func drawGrid() {
        func colorForStep(_ step: Int) -> NSColor {
            let stops: [(n: Int, a: CGFloat)] = [(10, 0.3), (5, 0.2)]
            let alpha: CGFloat = stops.lazy.first(where : { step.isMultiple(of: $0.n) })?.a ?? 0.1
            return ThemeColor.grid.withAlphaComponent(alpha)
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
