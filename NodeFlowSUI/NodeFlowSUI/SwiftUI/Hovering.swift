//
//  Hovering.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 22/12/21.
//  Copyright © 2021 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import Cocoa

extension View {
    func whenHovered(_ mouseIsInside: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(mouseIsInside))
    }
}

struct MouseInsideModifier: ViewModifier {
    let mouseIsInside: (Bool) -> Void
    let options: NSTrackingArea.Options

    init(_ mouseIsInside: @escaping (Bool) -> Void, options: NSTrackingArea.Options = [.mouseEnteredAndExited, .inVisibleRect, .enabledDuringMouseDrag, .activeInKeyWindow]) {
             self.mouseIsInside = mouseIsInside
             self.options = options
         }

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Representable(mouseIsInside: mouseIsInside,
                              frame: proxy.frame(in: .global),
                              options: options)
            }
        )
    }

    private struct Representable: NSViewRepresentable {
        let mouseIsInside: (Bool) -> Void
        let frame: NSRect
        let options: NSTrackingArea.Options

        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.mouseIsInside = mouseIsInside
            return coordinator
        }

        class Coordinator: NSResponder {
            var mouseIsInside: ((Bool) -> Void)?

            override func mouseEntered(with event: NSEvent) {
                mouseIsInside?(true)
            }

            override func mouseExited(with event: NSEvent) {
                mouseIsInside?(false)
            }
        }

        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: frame)

            let trackingArea = NSTrackingArea(rect: frame,
                                              options: options,
                                              owner: context.coordinator,
                                              userInfo: nil)

            view.addTrackingArea(trackingArea)

            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {}

        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
        }
    }
}
