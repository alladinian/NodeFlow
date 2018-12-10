//
//  Extensions.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 10/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

// Numeric
extension Int {
    func isMultipleOf(_ n: Int) -> Bool {
        return self % n == 0
    }
}
