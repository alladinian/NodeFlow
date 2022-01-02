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

class LinkContext: ObservableObject {
    @Published var start: CGPoint = .zero
    @Published var end: CGPoint   = .zero
    @Published var isActive: Bool = true
    @Published var sourceProperty: NodeProperty?
    @Published var destinationProperty: NodeProperty?
}

struct BoardView : View {

    let graph: Graph
    
    @EnvironmentObject var linkContext: LinkContext

    @State private var gridSpacing = 10

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
                ConnectionLinkView(output: connection.output,
                                   input: connection.input)
            }

            ForEach(Array(graph.nodes)) { node in
                NodeView(node: node)
            }
        }
        .coordinateSpace(name: "GridView")
        .onTapGesture {
            DispatchQueue.main.async {
                // Unfocus controls on bg tap
                NSApp.keyWindow?.makeFirstResponder(nil)
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


