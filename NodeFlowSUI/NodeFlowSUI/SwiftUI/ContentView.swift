//
//  ContentView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

extension Graph {
    static var testGraph: Graph = {
        let nodes: Set<Node> = [MathNode(), MathNode(), MathNode(), ColorNode()]
        let graph = Graph(nodes: nodes)
        return graph
    }()
}

struct ContentView: View {
    @ObservedObject var graph: Graph
    var body: some View {
        BoardView(graph: graph)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(graph: Graph.testGraph)
    }
}
