//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {

    @State var property: NodeProperty
    @State var isHovering: Bool  = false
    @State var isConnected: Bool = false

    @EnvironmentObject var linkContext: LinkContext

    let borderColor    = Color("ConnectionBorder")
    let connectedColor = Color("Connection")

    let connectionSize: CGFloat = 14

    var shouldHighlight: Bool {
        isHovering || isConnected || (linkContext.sourceProperty?.id == property.id)
    }

    var body: some View {

        let hoverCircle = Circle()
            .inset(by: 3)
            .fill(shouldHighlight ? connectedColor : Color.clear)
            .opacity(shouldHighlight ? 0.5 : 1.0)

        func gesture(reader: GeometryProxy) -> some Gesture {
            DragGesture(coordinateSpace: .named("GridView"))
                .onChanged { value in
                    linkContext.start          = reader.frame(in: .named("GridView")).center
                    linkContext.end            = value.location
                    linkContext.isActive       = true
                    linkContext.sourceProperty = property
                }.onEnded { value in
                    linkContext.end                 = value.location
                    linkContext.isActive            = false
                    linkContext.sourceProperty      = nil
                    linkContext.destinationProperty = nil
                }
        }

        return GeometryReader { reader in
            Circle()
                .stroke(property.type.associatedColors.first!, lineWidth: 2)
                .overlay(hoverCircle)
                .aspectRatio(contentMode: .fit)
                .onHover { hovering in
                    isHovering = hovering
                }
                .gesture(gesture(reader: reader))
                .onReceive(linkContext.objectWillChange) { output in
                    DispatchQueue.main.async {
                        isHovering = reader.frame(in: .named("GridView")).contains(linkContext.end)

                        if isHovering, property.id != linkContext.sourceProperty?.id {
                            linkContext.destinationProperty = property
                        }
                    }
                }
        }.frame(width: connectionSize, height: connectionSize)

    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(property: NumberProperty(isInput: true))
            .previewDisplayName("Input")
            .padding()
            .coordinateSpace(name: "GridView")
            .environmentObject(LinkContext())
    }
}

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}
