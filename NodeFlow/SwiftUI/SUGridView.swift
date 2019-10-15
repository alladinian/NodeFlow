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
}

struct SUGridView : View {

    @State var nodes: [Int] = []

    @State var isDragging: Bool = false
    @State var start: CGPoint   = .zero
    @State var end: CGPoint     = .zero
    
    @EnvironmentObject var linkContext: LinkContext

    let gridSpacing = 10

    var gridImage: Image {
        return Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())
    }
    
    var body: some View {
        
        return ZStack {
            Rectangle()
                .fill(ImagePaint(image: gridImage))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contextMenu {
                    Button(action: {

                    }) {
                        Text("Add  Node")
                    }
                }

            if linkContext.isActive {
                LinkView(start: self.linkContext.start, end: self.linkContext.end)
            }

            ForEach(nodes, id: \.self) { node in
                NodeView(inputs: .constant(["1","2"]), output: .constant(""))
                    .draggable()
                    .offset(x: CGFloat(node) * 20, y: CGFloat(node) * 20)
            }

        }
        .coordinateSpace(name: "GridView")
    }
}

struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        SUGridView(nodes: [1,2,3])
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
