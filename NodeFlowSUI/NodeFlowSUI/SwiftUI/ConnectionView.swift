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
        return isHovering || isConnected || (linkContext.sourceProperty?.id == property.id) || (linkContext.destinationProperty?.id == property.id)
    }

    var body: some View {

        let hoverCircle = Circle()
            .inset(by: 3)
            .fill(shouldHighlight ? connectedColor : Color.clear)
            .opacity(shouldHighlight ? 0.5 : 1.0)

        let titleLabel = Text(property.name)
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(Color("Text"))

        return HStack(alignment: .center) {

            if !property.isInput {
                Spacer()
                titleLabel
            }

            GeometryReader { reader in
                Circle()
                    .stroke(self.property.type.associatedColors.first!, lineWidth: 2)
                    .overlay(hoverCircle)
                    .aspectRatio(contentMode: .fit)
                    .onHover { hovering in
                        self.isHovering = hovering
                    }.gesture(DragGesture(coordinateSpace: .named("GridView")).onChanged { value in
                        self.linkContext.start          = reader.frame(in: .named("GridView")).center
                        self.linkContext.end            = value.location
                        self.linkContext.isActive       = true
                        self.linkContext.sourceProperty = self.property
                    }.onEnded { value in
                        self.linkContext.end                 = value.location
                        self.linkContext.isActive            = false
                        self.linkContext.sourceProperty      = nil
                        self.linkContext.destinationProperty = nil
                    })
                    .onReceive(self.linkContext.objectWillChange) { output in
                        if reader.frame(in: .named("GridView")).contains(self.linkContext.end), self.property.id != self.linkContext.sourceProperty!.id {
                            DispatchQueue.main.async {
                                self.linkContext.destinationProperty = self.property
                            }
                        }
                    }
            }.frame(width: self.connectionSize, height: self.connectionSize)

            if property.isInput {
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
            ConnectionView(property: NumberProperty(isInput: true)).previewDisplayName("Input")
            ConnectionView(property: NumberProperty(isInput: false)).previewDisplayName("Output")
        }.padding()
    }
}

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}
