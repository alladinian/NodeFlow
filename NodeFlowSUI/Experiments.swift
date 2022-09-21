//
//  Experiments.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 7/8/22.
//  Copyright © 2022 Vasilis Akoinoglou. All rights reserved.
//

import Foundation
import CoreImage

enum Input {
    case number
    case ciImage
}

enum Output {
    case number
    case ciImage
}

protocol ENode {
    var inputs: [Input]    { get set }
    var outputs: [Output] { get }
}

class FilterNode: ENode {
    var inputs: [Input]   = [.ciImage]
    var outputs: [Output] = [.ciImage]
}
