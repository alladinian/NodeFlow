//
//  ContentView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

class MasterOutput: ObservableObject {
    @Published var image: CIImage?
    
    func render(value: Any?) {
        guard let color = value as? Color, let cgColor = color.cgColor else { return }
        let ciColor = CIColor(cgColor: cgColor)
        DispatchQueue.main.async {
            self.image = CIImage(color: ciColor)
        }
    }
}

let MASTER = MasterOutput()

extension Graph {
    static var testGraph: Graph = {
        let nodes: Set<Node> = [ColorNode(), MasterNode()]
        let graph = Graph(nodes: nodes)
        return graph
    }()
}

struct ContentView: View {
    @ObservedObject var graph: Graph
    @ObservedObject var master = MASTER
    var body: some View {
        VStack {
            MetalView(image: master.image)
            BoardView(graph: graph)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(graph: Graph.testGraph)
    }
}
