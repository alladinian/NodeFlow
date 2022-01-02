//
//  ContentView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let nodes: Set<Node> = [MathNode(), MathNode(), MathNode(), MathNode()]
    var body: some View {
        BoardView(graph: Graph(nodes: nodes))
            .environmentObject(LinkContext())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
