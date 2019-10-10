//
//  NodeView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 20/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct NodeView: View {

    @State var name: String = "Node"

    @Binding var inputs: [String]?
    @Binding var output: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            Rectangle()
                .fill(Color("NodeHeader"))
                .frame(height: 40)
                .overlay(
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                )

            VStack {
                ForEach(inputs ?? [], id: \.self) { input in
                    ConnectionView(isInput: true)
                }
            }
            .padding()

            Spacer()

            Divider()

            ConnectionView(isInput: false)
                .padding()

        }
        .background(Color("NodeBackground"))
        .cornerRadius(8)
        .shadow(radius: 16)
        .fixedSize()
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView(inputs: .constant(["", ""]), output: .constant(""))
            .padding()
    }
}
