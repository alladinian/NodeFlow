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

    func propertyViews(from properties: [NodeProperty]) -> some View {
        ForEach(properties) { property in
            switch property.type {
            case .number:
                NumberPropertyView(property: property as! NumberProperty)
            case .picker:
                PickerPropertyView(property: property as! PickerProperty)
            default:
                EmptyView()
            }
        }
    }

    var inputs: some View {
        VStack(alignment: .trailing) {
            propertyViews(from: node.inputs)
        }
    }

    var outputs: some View {
        VStack {
            propertyViews(from: node.outputs)
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
    static var previews: some View {
        Group {
            NodeView(node: MathNode())
        }
        .padding()
        .background(Color.black)
        .environmentObject(LinkContext())
    }
}
