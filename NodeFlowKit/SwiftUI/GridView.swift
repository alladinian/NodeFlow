//
//  GridView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 19/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct GridView : View {

    @State var isDragging: Bool = false
    @State var start: CGPoint = .zero
    @State var end: CGPoint = .zero
    
    var body: some View {
        let drag = DragGesture().onChanged { (value) in
            self.start = value.startLocation
            self.end = value.location
            self.isDragging = true
        }.onEnded { (value) in
            self.isDragging = false
        }
        
        return ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(drag)
            if self.isDragging {
                LinkView(start: start, end: end)
            }
        }
    }
}

#if DEBUG
struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        GridView().previewLayout(.fixed(width: 400, height: 400))
    }
}
#endif

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
        }.stroke(Color.white, lineWidth: 5)
    }
}
