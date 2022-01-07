//
//  Dragging.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 11/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

// MARK: - Modifier Implementation
struct Draggable: ViewModifier {
    @Binding var offset: CGPoint

    var onStarted: (() -> ())? = nil

    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero

    func body(content: Content) -> some View {
        let drag       = DragGesture().onChanged { (value) in
            offset     = (dragOffset + value.translation).toPoint()
            if !isDragging {
                onStarted?()
            }
            isDragging = true
        }.onEnded { (value) in
            isDragging = false
            offset     = (dragOffset + value.translation).toPoint()
            dragOffset = offset.toSize()
        }
        return content.offset(offset).gesture(drag)
    }
}

func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

extension CGPoint {
    func toSize() -> CGSize {
        CGSize(x, y)
    }
}

extension CGSize {
    func toPoint() -> CGPoint {
        CGPoint(width, height)
    }
}

/*
// MARK: - ViewBuilder Implementation
struct DraggableView<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content().modifier(Draggable())
    }

}
 */

extension View {
    func draggable(offset: Binding<CGPoint>, onStarted: (() -> ())? = nil) -> some View {
        modifier(Draggable(offset: offset, onStarted: onStarted))
    }
}
