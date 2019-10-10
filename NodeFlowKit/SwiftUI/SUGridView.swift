//
//  GridView.swift
//  SUIMac
//
//  Created by Vasilis Akoinoglou on 19/6/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

struct DraggableView<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    @State var isDragging: Bool = false

    @State var offset: CGSize = .zero
    @State var dragOffset: CGSize = .zero

    var body: some View {
        let drag = DragGesture().onChanged { (value) in
            self.offset = self.dragOffset + value.translation
            self.isDragging = true
        }.onEnded { (value) in
            self.isDragging = false
            self.offset = self.dragOffset + value.translation
            self.dragOffset = self.offset
        }

        return content()
            .offset(offset)
            .gesture(drag)
    }

}

struct SUGridView : View {

    @State var isDragging: Bool = false
    @State var start: CGPoint = .zero
    @State var end: CGPoint = .zero

    let gridSpacing = 10

    var gridImage: Image {
        return Image(nsImage: GridView(frame: CGRect(x: 0, y: 0, width: 10 * gridSpacing, height: 10 * gridSpacing)).image())
    }
    
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
                .fill(ImagePaint(image: gridImage))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(drag)
            DraggableView {
                Rectangle().frame(width: 80, height: 80)
            }
            if self.isDragging {
                LinkView(start: self.start, end: self.end)
            }
        }
    }
}

#if DEBUG
struct GridView_Previews : PreviewProvider {
    static var previews: some View {
        SUGridView().previewLayout(.fixed(width: 400, height: 400))
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
        }.stroke(Color(ThemeColor.tint), lineWidth: 5)
    }
}


// Bad performance

//            // Vertical Steps ↓
//            ForEach(1...self.stepsForGeometry(geometry).v, id: \.self) { step in
//                Path { path in
//                    let points = self.pointsForStep(step, isVertical: true, bounds: geometry.size)
//                    path.move(to: points.start)
//                    path.addLine(to: points.end)
//                }
//                .stroke(lineWidth: 1)
//                .foregroundColor(self.colorForStep(step))
//            }
//
//            // Horizontal Steps →
//            ForEach(1...self.stepsForGeometry(geometry).h, id: \.self) { step in
//                Path { path in
//                    let points = self.pointsForStep(step, isVertical: false, bounds: geometry.size)
//                    path.move(to: points.start)
//                    path.addLine(to: points.end)
//                }
//                .stroke(lineWidth: 1)
//                .foregroundColor(self.colorForStep(step))
//            }
