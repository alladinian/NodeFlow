//
//  ColorPropertyView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 2/1/22.
//  Copyright © 2022 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct ColorPropertyView: View {
    @ObservedObject var property: NodeProperty
    var body: some View {
        PropertyView(property: property) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ColorPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPropertyView(property: NodeProperty())
    }
}
