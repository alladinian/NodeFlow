//
//  NumberPropertyView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 17/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct NumberPropertyView: View {
    @ObservedObject var property: NumberProperty

    var body: some View {
        HStack {
            if property.isInput {
                SocketView(property: property)
            }
            TextField("0", value: $property.number, formatter: NumberFormatter())
                .frame(maxWidth: 100)
                .textFieldStyle(DefaultTextFieldStyle())
            if !property.isInput {
                SocketView(property: property)
            }
        }
    }
}

struct NumberPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        NumberPropertyView(property: NumberProperty())
            .environmentObject(LinkContext())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
