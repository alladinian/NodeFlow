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

    let isSelected: Bool

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
            property.controlView
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

    func selectNode() {
        DispatchQueue.main.async {
            if NSEvent.modifierFlags.contains(.shift) || NSEvent.modifierFlags.contains(.option) {
                node.graph?.selectionContext.selectedNodes.insert(node)
            } else {
                node.graph?.selectionContext.selectedNodes = [node]
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if !node.inputs.isEmpty {
                inputs.padding()
                Divider()
            }
            outputs.padding()
        }
        .background(Color("NodeBackground").opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 16)
        .frame(minWidth: 150)
        .fixedSize()
        .strokeRoundedRectangle(8, Color.accentColor.opacity(isSelected ? 1 : 0.3), lineWidth: isSelected ?  2 : 1)
        .shadow(color: isSelected ? .accentColor.opacity(0.6) : .clear, radius: 6, x: 0, y: 0)
        .zIndex(isSelected ? 2 : 1)
        .draggable(offset: $node.offset, onStarted: selectNode)
        .onTapGesture(perform: selectNode)
//        .geometryReader { reader in
//            DispatchQueue.main.async {
//                node.frame = reader.frame(in: .gridView)
//                print(node.frame)
//            }
//        }
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NodeView(node: MathNode(), isSelected: false)
            NodeView(node: MathNode(), isSelected: true)
            NodeView(node: ColorNode(), isSelected: false)
        }
        .padding(40)
        .background(Color.black)
        .environmentObject(LinkContext())
    }
}
