//
//  ConnectionView.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ConnectionView : View {

    @State var title: String     = "Input / Output"
    @State var isHovering: Bool  = false
    @State var isConnected: Bool = true
    @State var isInput: Bool

    let borderColor    = Color("ConnectionBorder")
    let connectedColor = Color("Connection")

    var body: some View {
        return HStack(alignment: .center) {
            if !isInput {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color("Text"))
            }

            Circle()
                .stroke(borderColor, lineWidth: 2)
                .overlay(
                    Circle()
                        .inset(by: 3)
                        .fill(isHovering ? connectedColor : Color.clear)
                        .opacity(isHovering ? 0.5 : 1.0)
                )
                .frame(width: 16, height: 16)
                .onHover { hovering in
                    self.isHovering = hovering
                }

            if isInput {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color("Text"))
            }
        }.frame(minWidth: 100)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionView(title: "Input", isInput: true)
            ConnectionView(title: "Output", isInput: false)
        }.padding()
    }
}
