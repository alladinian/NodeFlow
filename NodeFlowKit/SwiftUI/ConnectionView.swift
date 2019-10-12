//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {

    @State var title: String     = "Input / Output"
    @State var isHovering: Bool  = false
    @State var isDragging: Bool  = false
    @State var isConnected: Bool = true
    @State var isInput: Bool

    @EnvironmentObject var linkContext: LinkContext

    let borderColor    = Color("ConnectionBorder")
    let connectedColor = Color("Connection")

    let connectionSize: CGFloat = 16

    var body: some View {

        let dragGesture = DragGesture(coordinateSpace: .named("GridView")).onChanged({ value in
            self.isDragging           = true
            self.linkContext.start    = value.startLocation
            self.linkContext.end      = value.location
            self.linkContext.isActive = true
        }).onEnded({ value in
            self.isDragging           = false
            self.linkContext.isActive = false
        })

        let circle = Circle()
            .inset(by: 3)
            .fill((isHovering || isDragging) ? connectedColor : Color.clear)
            .opacity((isHovering || isDragging) ? 0.5 : 1.0)

        let titleLabel = Text(title)
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(Color("Text"))

        return HStack(alignment: .center) {

            if !isInput {
                Spacer()
                titleLabel
            }

            Circle()
                .stroke(borderColor, lineWidth: 2)
                .overlay(circle)
                .frame(width: connectionSize, height: connectionSize)
                .onHover { hovering in
                    self.isHovering = hovering
                }.gesture(dragGesture)

            if isInput {
                titleLabel
                Spacer()
            }

        }
        .frame(minWidth: 100)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionView(title: "Input", isInput: true).previewDisplayName("Input")
            ConnectionView(title: "Output", isInput: false).previewDisplayName("Output")
        }.padding()
    }
}
