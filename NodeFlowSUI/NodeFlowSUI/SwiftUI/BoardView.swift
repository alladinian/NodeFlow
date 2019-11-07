//
//  GridView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 19/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

class LinkContext: ObservableObject {
    @Published var start: CGPoint = .zero
    @Published var end: CGPoint = .zero
    @Published var isActive: Bool = true
    @Published var sourceProperty: NodeProperty?
    @Published var destinationProperty: NodeProperty?
}

struct BoardView : View {

    let board: Board

    @State private var isDragging: Bool = false
    @State private var start: CGPoint   = .zero
    @State private var end: CGPoint     = .zero
    
    @EnvironmentObject var linkContext: LinkContext

    @State private var gridSpacing = 10

    var gridImage: Image {
        return Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())
    }
    
    var body: some View {
        
        return ZStack {
            Rectangle()
                .fill(ImagePaint(image: self.gridImage))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contextMenu {
                    Button("Add Node") {

                    }
                }

            if self.linkContext.isActive {
                LinkView(start: self.linkContext.start, end: self.linkContext.end)
            }

            ForEach(self.board.connections, id: \.id) { connection in
                EmptyView()
            }

            ForEach(self.board.nodes, id: \.id) { node in
                NodeView(node: node)
                    .draggable()
            }

        }
        .coordinateSpace(name: "GridView")
    }
}

struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        BoardView(board: Board(nodes: [MathNode()], connections: []))
            .environmentObject(LinkContext())
            .previewLayout(.fixed(width: 400, height: 400))
    }
}

struct LinkView : View {
    var start: CGPoint
    var end: CGPoint
    
    var body: some View {
        var inputPoint = start
        var outputPoint = end
        
        if inputPoint.x > outputPoint.x {
            swap(&inputPoint, &outputPoint)
        }
        
        let th = max((outputPoint.x - inputPoint.x) / 2, 0)
        
        let p1 = CGPoint(x: inputPoint.x + th, y: inputPoint.y)
        let p2 = CGPoint(x: outputPoint.x - th, y: outputPoint.y)
        
        return Path { path in
            path.move(to: inputPoint)
            path.addCurve(to: outputPoint, control1: p1, control2: p2)
        }
        .stroke(Color("Tint"), lineWidth: 3)
    }
}
