//
//  GridView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 19/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

extension CoordinateSpace {
    static let gridView = CoordinateSpace.named("GridView")
}

struct BoardView : View {

    @ObservedObject var graph: Graph

    private let gridSpacing = 10

    @ObservedObject private var linkContext: LinkContext
    @ObservedObject private var selectionContext: SelectionContext

    init(graph: Graph) {
        self.graph            = graph
        self.linkContext      = graph.linkContext
        self.selectionContext = graph.selectionContext
    }

    var gridImage: Image {
        Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(ImagePaint(image: gridImage))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6)
                .contextMenu {
                    Button("Add Node") {

                    }
                }

            if linkContext.isActive {
                LinkView(start: linkContext.start, end: linkContext.end)
            }

            ForEach(Array(graph.connections)) { connection in
                ConnectionLinkView(output: connection.output, input: connection.input)
            }

            ForEach(Array(graph.nodes)) { node in
                NodeView(node: node, isSelected: selectionContext.selectedNodes.contains(node))
            }
        }
        .environmentObject(graph.linkContext)
        .environmentObject(graph.selectionContext)
        .coordinateSpace(name: "GridView")
        .onTapGesture {
            DispatchQueue.main.async {
                // Unfocus controls on bg tap
                NSApp.keyWindow?.makeFirstResponder(nil)
                selectionContext.selectedNodes = []
            }
        }
    }
}

struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        BoardView(graph: Graph(nodes: [MathNode()]))
            .environmentObject(LinkContext())
            .previewLayout(.fixed(width: 400, height: 400))
    }
}


