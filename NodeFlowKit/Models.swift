//
//  Models.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation


/*----------------------------------------------------------------------------*/

public protocol Connection {
    var input: Property? { get }
    var output: Property? { get }

    init(input: Property, output: Property)
}

/*----------------------------------------------------------------------------*/

public protocol Node {
    var inputs: [Property] { get }
    var outputs: [Property] { get }
    var evaluationFunction: (Property) -> Void { get set }

    init(inputs: [Property], outputs: [Property], evaluationFunction: @escaping ((Property) -> Void))
}

/*----------------------------------------------------------------------------*/

public protocol Graph {
    var nodes: [Node] { get }
    var connections: [Connection] { get set }

    init(nodes: [Node], connections: [Connection])

    func evaluate()
}
