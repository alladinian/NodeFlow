//
//  Fixtures.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 16/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class NumberProperty: NodeProperty {

    static let formatter: NumberFormatter = {
        let formatter                     = NumberFormatter()
        formatter.numberStyle             = .decimal
        formatter.maximumFractionDigits   = 2
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
}

class PickerProperty: NodeProperty {

    let options: [String]

    @Published var selection: String {
        didSet {
            value = selection
        }
    }

    init(options: [String]) {
        self.options   = options
        self.selection = options.first!
        super.init()
        self.name      = "Picker"
        self.type      = .picker
    }
}

class ColorProperty: NodeProperty {

    var color: Color {
        get { value as? Color ?? .purple }
        set { value = newValue }
    }

    override init() {
        super.init()
        self.name  = "Color"
        self.type  = .color
        self.value = Color.purple
    }
}

//MARK: - Node Factory

class MathNode: Node {

    // https://docs.blender.org/manual/en/latest/modeling/geometry_nodes/utilities/math.html

    enum Operation: String, CaseIterable, CustomStringConvertible {
        case add, subtract, multiply, divide
        case power, log, squareRoot, iSquareRoot
        case absolute, exponent

        case min, max, ltn, gtn, sign, compare

        case round, floor, ceil
        case truncate, fraction, modulo, wrap
        case snap
        case pingPong

        case sin, cos, tan
        case asin, acos, atan, atan2
        case hsin, hcos, htan

        case rad, deg

        case clamp

        var description: String { rawValue }

        func transform(_ a: Double, _ b: Double) -> Double {
            switch self {
            case .add:      return a + b
            case .subtract: return a - b
            case .multiply: return a * b
            case .divide:   return a / b

            case .power:    return Foundation.pow(a, b)
            case .log:      return Foundation.log(a) / Foundation.log(b)

            case .min: return Swift.min(a, b)
            case .max: return Swift.max(a, b)
            case .ltn: return a < b ? 1 : 0
            case .gtn: return a > b ? 1 : 0

            default: return a + b
            }
        }
    }

    override init() {
        super.init()
        self.name = "Math"

        self.inputs  = [
            NumberProperty(),
            NumberProperty(),
            PickerProperty(options: Operation.allCases.map(\.description)),
        ]

        self.outputs = [
            NumberProperty()
        ]

        Publishers
            .CombineLatest3(
                inputs[0].$value.map { $0 as? Double }.replaceNil(with: 0),
                inputs[1].$value.map { $0 as? Double }.replaceNil(with: 0),
                inputs[2].$value.map { $0 as? String }.replaceNil(with: Operation.allCases.first!.description)
            )
            .map { a, b, c in
                Operation(rawValue: c)?.transform(a, b)
            }
            .receive(on: RunLoop.main)
            .assign(to: \.value, on: self.outputs[0])
            .store(in: &cancellables)
    }

}

class OscillatorNode: Node {
    enum OscillationFunction: String, CaseIterable, CustomStringConvertible {
        case sin, cos

        func transform(_ a: Double) -> Double {
            switch self {
            case .sin:
                return Foundation.sin(a)
            case .cos:
                return Foundation.cos(a)
            }
        }

        var description: String { rawValue }
    }

    @Published var function: OscillationFunction = .sin

    override init() {
        super.init()
        self.name = "Oscillator"

        self.inputs = [
            PickerProperty(options: OscillationFunction.allCases.map(\.description))
        ]

        self.outputs = [
            NumberProperty()
        ]

        Timer.publish(every: 1.0 / 30.0, on: .main, in: .default)
            .autoconnect()
            .combineLatest($function)
            //.receive(on: RunLoop.main)
            .map { time, function in
                function.transform(time.timeIntervalSince1970)
            }
            .assign(to: \.value, on: self.outputs[0])
            .store(in: &cancellables)
    }
}

class ColorNode: Node {
    override init() {
        super.init()
        self.name    = "Color"
        self.outputs = [ColorProperty()]
    }
}

class MasterNode: Node {
    override init() {
        super.init()
        self.name    = "Master"
        self.inputs  = [ColorProperty()]
        self.outputs = []
        
        self.inputs[0].$value
            .sink(receiveValue: { value in
                MASTER.render(value: value)
            })
            .store(in: &cancellables)
    }

}
