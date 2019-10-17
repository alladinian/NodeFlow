//
//  ContentView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BoardView(board: Board(nodes: [MathNode()], connections: []))
        .environmentObject(LinkContext())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
