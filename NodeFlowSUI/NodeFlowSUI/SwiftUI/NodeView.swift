//
//  NodeView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 20/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct NodeView: View {

    let node: Node

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            Rectangle()
                .fill(Color("NodeHeader"))
                .frame(height: 40)
                .overlay(
                    Text(node.name)
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                )

            VStack {
                ForEach(node.inputs, id: \.id) { input in
                    NumberPropertyView(number: .constant("1"), property: input)
                }
            }
            .padding()

            Spacer()

            Divider()

            VStack {
                ForEach(node.outputs, id: \.id) { output in
                    NumberPropertyView(number: .constant("1"), property: output)
                }
            }
            .padding()

        }
        .background(Color("NodeBackground").opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 16)
        .frame(minWidth: 150)
        .fixedSize()
    }
}

struct NodeView_Previews: PreviewProvider {
    static let node = MathNode()

    static var previews: some View {
        NodeView(node: node)
            .environmentObject(LinkContext())
            .padding()
    }
}
