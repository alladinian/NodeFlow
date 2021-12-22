//
//  ContentView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let nodes = [MathNode(), MathNode(), MathNode(), MathNode()]
    var body: some View {
        BoardView(board: Board(nodes: nodes, connections: []))
            .environmentObject(LinkContext())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
