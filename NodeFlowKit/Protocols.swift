//
//  Protocols.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

public protocol PropertyValue {

}

public protocol Property: class {
    var name: String { get set }
    var value: Any? { get set }
}

extension NSColor: PropertyValue {}

extension NSImage: PropertyValue {}

extension CGFloat: PropertyValue {}
