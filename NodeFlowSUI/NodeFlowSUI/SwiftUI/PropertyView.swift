//
//  PropertyView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 2/1/22.
//  Copyright © 2022 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

struct PropertyView<Content: View>: View {
    let property: NodeProperty
    let content: Content

    init(property: NodeProperty, @ViewBuilder content: () -> Content) {
        self.property = property
        self.content = content()
    }

    var body: some View {
        HStack {
            if property.isInput, property.hasSocket {
                SocketView(property: property)
                Spacer()
            }
            content
                .disabledIf(property.isInput && property.isConnected)
                .disabledIf(!property.isInput && property.node?.inputs.count ?? 0 > 0)
            if !property.isInput, property.hasSocket {
                Spacer()
                SocketView(property: property)
            }
        }
    }
}
