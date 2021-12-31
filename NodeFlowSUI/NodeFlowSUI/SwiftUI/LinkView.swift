//
//  LinkView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/11/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct LinkView : View {
    var start: CGPoint
    var end: CGPoint

    var body: some View {
        var inputPoint = start
        var outputPoint = end

        if inputPoint.x > outputPoint.x {
            swap(&inputPoint, &outputPoint)
        }

        let threshold = max((outputPoint.x - inputPoint.x) / 2, 0)

        let p1 = CGPoint(x: inputPoint.x + threshold, y: inputPoint.y)
        let p2 = CGPoint(x: outputPoint.x - threshold, y: outputPoint.y)

        return Path { path in
            path.move(to: inputPoint)
            path.addCurve(to: outputPoint, control1: p1, control2: p2)
        }
        .stroke(Color("Tint"), lineWidth: 3)
    }
}

//extension LinkView {
//    init(connection: Connection) {
//
//    }
//}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(start: .zero, end: CGPoint(x: 100, y: 100))
            .previewLayout(.fixed(width: 130, height: 130))
            .padding()
    }
}
