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

    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
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
        get { NumberProperty.formatter.string(for: value) ?? "0" }
        set { value = Double(newValue) }
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

//MARK: - Node Factory

class MathNode: Node {

    /**
     Operation
     The mathematical operator to be applied to the input values:

     Functions
     Add
     The sum of the two values.
     Subtract
     The difference between the two values.
     Multiply
     The product of the two values.
     Divide
     The division of the first value by the second value.
     Multiply Add
     The sum of the product of the two values with Addend.
     Power
     The Base raised to the power of Exponent.
     Logarithm
     The log of the value with a Base as its base.
     Square Root
     The square root of the value.
     Inverse Square Root
     One divided by the square root of the value.
     Absolute
     The input value is read without regard to its sign. This turns negative values into positive values.
     Exponent
     Raises Euler’s number to the power of the value.
     Comparison
     Minimum
     Outputs the smallest of the input values.
     Maximum
     Outputs the largest of two input values.
     Less Than
     Outputs 1.0 if the first value is smaller than the second value. Otherwise the output is 0.0.
     Greater Than
     Outputs 1.0 if the first value is larger than the second value. Otherwise the output is 0.0.
     Sign
     Extracts the sign of the input value. All positive numbers will output 1.0. All negative numbers will output -1.0. And 0.0 will output 0.0.
     Compare
     Outputs 1.0 if the difference between the two input values is less than or equal to Epsilon.
     Smooth Minimum
     Smooth Minimum.
     Smooth Maximum
     Smooth Maximum.
     Rounding
     Round
     Rounds the input value to the nearest integer.
     Floor
     Rounds the input value down to the nearest integer.
     Ceil
     Rounds the input value up to the nearest integer.
     Truncate
     Outputs the integer part of the value.
     Fraction
     Fraction.
     Modulo
     Outputs the remainder once the first value is divided by the second value.
     Wrap
     Outputs a value between Min and Max based on the absolute difference between the input value and the nearest integer multiple of Max less than the value.
     Snap
     Rounds the input value down to the nearest integer multiple of Increment.
     Ping-pong
     The output value is moved between 0.0 and the Scale based on the input value.
     Trigonometric
     Sine
     The Sine of the input value.
     Cosine
     The Cosine of the input value.
     Tangent
     The Tangent of the input value.
     Arcsine
     The Arcsine of the input value.
     Arccosine
     The Arccosine of the input value.
     Arctangent
     The Arctangent of the input value.
     Arctan2
     Outputs the Inverse Tangent of the first value divided by the second value measured in radians.
     Hyperbolic Sine
     The Hyperbolic Sine of the input value.
     Hyperbolic Cosine
     The Hyperbolic Cosine of the input value.
     Hyperbolic Tangent
     The Hyperbolic Tangent of the input value.
     Conversion
     To Radians
     Converts the input from degrees to radians.
     To Degrees
     Converts the input from radians to degrees.
     Clamp
     Limits the output to the range (0.0 to 1.0). See Clamp.
     */

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

        func transform(_ a: Double, _ b: Double) -> Double { //<T: BinaryFloatingPoint>() -> (T, T) -> T {
            switch self {
            case .add:      return a + b
            case .subtract: return a - b
            case .multiply: return a * b
            case .divide:   return a / b

            default: return a + b
            }
        }
    }

    override init() {
        super.init()
        self.name    = "Math"

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
                let operation = Operation(rawValue: c)
                return operation?.transform(a, b)
            }
            .assign(to: \.value, on: self.outputs[0])
            .store(in: &cancellables)
    }

}
