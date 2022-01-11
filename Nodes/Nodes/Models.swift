//
//  Models.swift
//  Nodes
//
//  Created by Vasilis Akoinoglou on 11/1/22.
//

import Foundation
import CoreData
import SwiftUI
import PureSwiftUI
import Combine

@objc(NodeProperty)
public class NodeProperty: NSManagedObject {

    var controlView: AnyView {
        EmptyView().asAnyView
    }
    
}

@objc(Connection)
public class Connection: NSManagedObject {

    var cancellable: AnyCancellable?

    init(output: NodeProperty, input: NodeProperty, context: NSManagedObjectContext) {
        super.init(entity: NodeProperty.entity(), insertInto: context)
        self.input  = input
        self.output = output
    }

    func setup() {
        [output!, input!].forEach { $0.isConnected = true }
        cancellable = output!.publisher(for: \.value)
            .receive(on: RunLoop.main, options: nil)
            .assign(to: \.value, on: input!)
    }

    func tearUp() {
        [output!, input!].forEach { $0.isConnected = false }
        input!.value = nil
        cancellable?.cancel()
    }

    deinit {
        print("Deallocated \(self)")
    }

}

@objc(Node)
public class Node: NSManagedObject {

    var cancellables: Set<AnyCancellable> = []
    
}

@objc(Graph)
public class Graph: NSManagedObject {

    enum ConnectionError: LocalizedError {
        case sameNode
        case typeMismatch
        case feedbackLoop
        case inputOccupied

        var errorDescription: String? {
            switch self {
            case .sameNode:
                return "Attempted connection on the same node"
            case .typeMismatch:
                return "Property types do not match"
            case .feedbackLoop:
                return "Connection causes a feedback loop"
            case .inputOccupied:
                return "Input is already occupied"
            }
        }
    }

    let linkContext = LinkContext()
    lazy var selectionContext = SelectionContext(graph: self)

}

class LinkContext: ObservableObject {
    var start: CGPoint { sourceProperty?.frame?.rectValue.center ?? .zero }
    @Published var end: CGPoint   = .zero
    @Published var isActive: Bool = false
    @Published var sourceProperty: NodeProperty?
    @Published var destinationProperty: NodeProperty?
}

class SelectionContext: ObservableObject {
    weak var graph: Graph?

    @Published var selectedNodes: Set<Node> = []
    @Published var selectionRect: CGRect = .zero
    @Published var hasSelection: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    init(graph: Graph) {
        self.graph = graph
        $selectedNodes
            .map(\.isNotEmpty)
            .assign(to: \.hasSelection, on: self)
            .store(in: &cancellables)
    }
}
