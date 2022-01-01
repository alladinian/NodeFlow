//
//  SocketView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

extension NSNotification.Name {
    static let didStartDrawingLine  = NSNotification.Name("userDidStartDrawingLine")
    static let didFinishDrawingLine = NSNotification.Name("userDidFinishDrawingLine")
}

struct SocketView: View, DropDelegate {

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

    func dragGesture(reader: GeometryProxy) -> some Gesture {
        DragGesture(coordinateSpace: .gridView)
            .onChanged { value in
                linkContext.start          = reader.frame(in: .gridView).center
                linkContext.end            = value.location
                linkContext.isActive       = true
                linkContext.sourceProperty = property
            }
            .onEnded { value in
                NotificationCenter.default.post(name: .didFinishDrawingLine, object: (property, value.location))
                linkContext.end                 = value.location
                linkContext.isActive            = false
                linkContext.sourceProperty      = nil
                linkContext.destinationProperty = nil
            }
    }

    var body: some View {
        let hoverCircle = Circle()
            .inset(by: 3)
            .fill(shouldHighlight ? connectedColor : Color.clear)
            .opacity(shouldHighlight ? 0.5 : 1.0)

        return GeometryReader { reader in
            Circle()
                .stroke(property.type.associatedColors.first!, lineWidth: 1.5)
                .overlay(hoverCircle)
                .aspectRatio(contentMode: .fit)
                .whenHovered { hovering in
                    isHovering = hovering
                }
                // .onDrag {
                //    NSItemProvider(object: property.id.debugDescription as NSString)
                //  }
                .gesture(dragGesture(reader: reader))
                .preference(key: SocketPreferenceKey.self,
                            value: [SocketPreferenceData(property: property,
                                                         frame: reader.frame(in: .gridView))])
                .onPreferenceChange(SocketPreferenceKey.self) { value in
                    if let data = value.first(where: { $0.property == property }) {
                        property.frame = data.frame
                    }
                }
                // .onDrop(of: [String(kUTTypeText)], delegate: self)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(connectionSize)

    }

    func performDrop(info: DropInfo) -> Bool {
        true
    }
}


struct SocketPreferenceData: Equatable {
    let property: NodeProperty
    let frame: CGRect
}

struct SocketPreferenceKey: PreferenceKey {
    typealias Value = [SocketPreferenceData]

    static var defaultValue: Value = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct SocketView_Previews: PreviewProvider {
    static var previews: some View {
        SocketView(property: NumberProperty(isInput: true))
            .previewDisplayName("Input")
            .padding()
            .coordinateSpace(name: "GridView")
            .environmentObject(LinkContext())
    }
}
