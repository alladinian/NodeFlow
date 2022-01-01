//
//  Fixtures.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import Combine

class NumberProperty: NodeProperty {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    override init() {
        super.init()
        self.name = "Number"
        self.type = .number
    }

    var number: Double {
        get { value as? Double ?? 0}
        set { value = newValue }
    }

    var stringValue: String {
        get { Self.formatter.string(for: value) ?? "0" }
        set { value = Double(newValue) }
    }
}

//MARK: - Node Factory

class MathNode: Node {

    override init() {
        super.init()
        self.name    = "Math"
        self.inputs  = [NumberProperty(), NumberProperty()]
        self.outputs = [NumberProperty()]
        Publishers
            .CombineLatest(
                inputs[0].$value.map { $0 as? Double }.replaceNil(with: 0),
                inputs[1].$value.map { $0 as? Double }.replaceNil(with: 0)
            )
            .map { a, b in
                a + b
            }
            .assign(to: \.value, on: self.outputs[0])
            .store(in: &cancellables)
    }
}
