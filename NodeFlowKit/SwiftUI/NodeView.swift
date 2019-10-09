//
//  NodeView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 20/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct NodeView : View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ZStack {
                Rectangle().fill(Color.white).frame(height: 40)
                Text("Node")
                    .font(.headline)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .frame(height: 28)
            }
            VStack {
                ConnectionView(isInput: true)
                ConnectionView(isInput: true)
            }.padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .cornerRadius(8)
            .shadow(radius: 16)
            .padding() // just for preview
    }
}

struct ConnectionView : View {
    
    @State var title: String = "Connection_name"
    @State var isHovering: Bool = false
    @State var isConnected: Bool = true
    @State var isInput: Bool
    
    static var borderColor: Color { return Color.accentColor }
    static var connectedColor: Color { return Color.accentColor }
    
    var body: some View {
        return HStack(alignment: .center) {
            Circle()
                .stroke(Self.borderColor, lineWidth: 2)
                .overlay(
                    Circle()
                        .inset(by: 3)
                        .fill(isHovering ? Self.connectedColor : Color.black)
                        .opacity(isHovering ? 0.5 : 1.0)
                )
                .frame(width: 16, height: 16)
                .onHover { isInside in
                    self.isHovering = isInside
            }
            Text(title)
                .foregroundColor(Color.white)
        }
    }
}

#if DEBUG
struct NodeView_Previews : PreviewProvider {
    static var previews: some View {
        NodeView()
    }
}
#endif
