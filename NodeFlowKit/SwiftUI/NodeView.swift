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
            Rectangle()
                .fill(Color("NodeHeader"))
                .frame(height: 40)
                .overlay(
                    Text("Node")
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
            )
            VStack {
                ConnectionView(isInput: true)
                ConnectionView(isInput: true)
            }.padding()
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("NodeBackground"))
            .cornerRadius(8)
            .shadow(radius: 16)
            .padding() // just for preview
    }
}

struct NodeView_Previews : PreviewProvider {
    static var previews: some View {
        NodeView()
    }
}
