//
//  GridView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 19/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

extension CoordinateSpace {
    static let gridView = CoordinateSpace.named("GridView")
}

extension CGRect {
    init(p1: CGPoint, p2: CGPoint) {
        self.init(x: min(p1.x, p2.x),
                  y: min(p1.y, p2.y),
                  width: abs(p1.x - p2.x),
                  height: abs(p1.y - p2.y))
    }
}

private let gridSpacing = 10
private let gridImage: Image = Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())

struct BoardView : View {

    @ObservedObject var graph: Graph

    @ObservedObject private var linkContext: LinkContext
    @ObservedObject private var selectionContext: SelectionContext

    @State private var zoomFactor: CGFloat = 1

    init(graph: Graph) {
        self.graph            = graph
        self.linkContext      = graph.linkContext
        self.selectionContext = graph.selectionContext
    }

    var zoomControls: some View {
        HStack {
            Button {
                zoomFactor /= 1.1
            } label: {
                Label("", sfSymbol: .minus_magnifyingglass).labelStyle(.iconOnly)
            }.buttonStyle(.plain)

            Picker(selection: .constant(1), label: Text("Picker")) {
                Text("1").tag(1)
                Text("2").tag(2)
            }
            .labelsHidden()
            .fixedSize()

            Button {
                zoomFactor *= 1.1
            } label: {
                Label("", sfSymbol: .plus_magnifyingglass).labelStyle(.iconOnly)
            }.buttonStyle(.plain)

        }.padding()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(ImagePaint(image: gridImage))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6)

            if linkContext.isActive {
                LinkView(start: linkContext.start, end: linkContext.end)
            }

            ForEach(Array(graph.connections)) { connection in
                ConnectionLinkView(output: connection.output, input: connection.input)
            }

            ForEach(Array(graph.nodes)) { node in
                NodeView(node: node, isSelected: selectionContext.selectedNodes.contains(node))
            }

            if selectionContext.selectionRect != .zero {
                Rectangle()
                    .stroke(Color.cgLightGray)
                    .background(Color.cgLightGray.opacity(0.1))
                    .frame(selectionContext.selectionRect.size)
                    .offset(selectionContext.selectionRect.origin)
                    .zIndex(10)
            }
        }
        .environmentObject(graph.linkContext)
        .coordinateSpace(name: "GridView")
        .onTapGesture {
            DispatchQueue.main.async {
                // Unfocus controls on bg tap
                NSApp.keyWindow?.makeFirstResponder(nil)
                selectionContext.selectedNodes = []
            }
        }
        .gesture(
            DragGesture().onChanged { value in
                let p1 = value.startLocation
                let p2 = value.location
                selectionContext.selectionRect = CGRect(p1: p1, p2: p2)
            }.onEnded { value in
                selectionContext.selectionRect = .zero
            }
        )
        .contextMenu {
            Button("Add Node") {

            }
        }
        .padding()
        //.scale(zoomFactor)
        //.overlay(zoomControls, alignment: .bottomLeading)
    }
}

struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        BoardView(graph: Graph(nodes: [MathNode()]))
            .previewLayout(.fixed(width: 400, height: 400))
    }
}


