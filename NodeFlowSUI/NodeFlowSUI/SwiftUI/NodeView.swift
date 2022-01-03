//
//  NodeView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 20/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

struct NodeView: View {

    @ObservedObject var node: Node

    var header: some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(height: 40)
            .overlay(
                Text(node.name)
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .shadow(1)
            )
    }

    var inputs: some View {
        VStack(alignment: .trailing) {
            ForEach(node.inputs) { input in
                switch input.type {
                case .number:
                    NumberPropertyView(property: input as! NumberProperty)
                case .picker:
                    PickerPropertyView(property: input as! PickerProperty)
                default:
                    EmptyView()
                }
            }
        }
    }

    var outputs: some View {
        VStack {
            ForEach(node.outputs) { output in
                switch output.type {
                case .number:
                    NumberPropertyView(property: output as! NumberProperty)
                default:
                    EmptyView()
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            header

            inputs
                .padding()

            Divider()

            outputs
                .padding()

        }
        .background(Color("NodeBackground").opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 16)
        .frame(minWidth: 150)
        .fixedSize()
        .strokeRoundedRectangle(8, Color.accentColor.opacity(0.3), lineWidth: 1)
        .draggable(offset: $node.position)
    }
}

struct NodeView_Previews: PreviewProvider {
    static let node = MathNode()

    static var previews: some View {
        NodeView(node: node)
            .padding()
            .background(Color.black)
    }
}
