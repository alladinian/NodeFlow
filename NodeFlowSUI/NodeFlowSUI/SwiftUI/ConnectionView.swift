//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

struct ConnectionView: View, DropDelegate {

    @EnvironmentObject var linkContext: LinkContext

    var property: NodeProperty
    var connectionSize: CGFloat = 12

    @State private var isHovering: Bool  = false
    @State private var isConnected: Bool = false

    private let borderColor    = Color.accentColor.opacity(0.95)
    private let connectedColor = Color.accentColor

    private var shouldHighlight: Bool {
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
                .stroke(property.type.associatedColors.first!, lineWidth: 1.5)
                .overlay(hoverCircle)
                .aspectRatio(contentMode: .fit)
                .whenHovered { hovering in
                    isHovering = hovering
                }
                .gesture(gesture(reader: reader))
                //.preference(key: ConnectionCenterPreferenceKey.self, value: reader.frame(in: .named("GridView")).center)
            /*
             .onDrag {
                NSItemProvider(object: property.id as NSString)
             }
             .onDrop(of: [String(kUTTypeText)], delegate: self)

             .onReceive(linkContext.objectWillChange) { output in
                    DispatchQueue.main.async {
                        isHovering = reader.frame(in: .named("GridView")).contains(linkContext.end)

                        if isHovering, property.id != linkContext.sourceProperty?.id {
                            linkContext.destinationProperty = property
                        }
                    }
                }
             */
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(connectionSize)

    }

    func performDrop(info: DropInfo) -> Bool {
        true
    }
}

/*
struct ConnectionCenterPreferenceData: Equatable {
    let property: NodeProperty
    let center: CGPoint
}

struct ConnectionCenterPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}
 */


struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(property: NumberProperty(isInput: true))
            .previewDisplayName("Input")
            .padding()
            .coordinateSpace(name: "GridView")
            .environmentObject(LinkContext())
    }
}
