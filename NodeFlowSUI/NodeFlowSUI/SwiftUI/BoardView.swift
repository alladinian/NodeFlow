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

    let board: Board
    
    @EnvironmentObject var linkContext: LinkContext

    @State private var gridSpacing = 10

    var gridImage: Image {
        Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())
    }
    
    var body: some View {
        //ScrollView {
            ZStack {
                Rectangle()
                    .fill(ImagePaint(image: gridImage))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contextMenu {
                        Button("Add Node") {

                        }
                    }

                if linkContext.isActive {
                    LinkView(start: linkContext.start, end: linkContext.end)
                }

                ForEach(Array(board.connections), id: \.id) { connection in
                    EmptyView()
                }

                ForEach(Array(board.nodes), id: \.id) { node in
                    NodeView(node: node)
                }

            }
            .coordinateSpace(name: "GridView")
        //}
    }
}

struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        BoardView(board: Board(nodes: [MathNode()], connections: []))
            .environmentObject(LinkContext())
            .previewLayout(.fixed(width: 400, height: 400))
    }
}


