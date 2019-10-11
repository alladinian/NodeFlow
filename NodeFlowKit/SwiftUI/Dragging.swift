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
    @State var isDragging: Bool = false

    @State var offset: CGSize = .zero
    @State var dragOffset: CGSize = .zero

    func body(content: Content) -> some View {
        let drag = DragGesture().onChanged { (value) in
            self.offset = self.dragOffset + value.translation
            self.isDragging = true
        }.onEnded { (value) in
            self.isDragging = false
            self.offset = self.dragOffset + value.translation
            self.dragOffset = self.offset
        }
        return content.offset(offset).gesture(drag)
    }
}

func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

// MARK: - ViewBuilder Implementation
struct DraggableView<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        return content().modifier(Draggable())
    }

}
