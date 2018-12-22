//
//  Colors.swift
//  NodeFlowKit
//
//  Created by Vasilis Akoinoglou on 22/12/2018.
//  Copyright © 2018 Vasilis Akoinoglou. All rights reserved.
//

import Foundation

struct ThemeColor {
    static let tint             = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)
    static let grid             = tint
    static let line             = tint
    static let connection       = tint
    static let connectionBorder = tint
    static let selection        = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.937254902, alpha: 1)
    static let background       = NSColor.windowBackgroundColor
    static let text             = NSColor.textColor
    static let nodeSelection    = NSColor.selectedControlColor
    static let nodeBackground   = NSColor.underPageBackgroundColor
    static let nodeHeader       = NSColor.textBackgroundColor
}
