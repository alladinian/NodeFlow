//
//  PropertiesFactory.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 17/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI
import PureSwiftUI

struct NumberPropertyView: View {
    @ObservedObject var property: NumberProperty

    var body: some View {
        PropertyView(property: property) {
            TextField("0", value: $property.number, formatter: NumberProperty.formatter)
                .frame(maxWidth: 100)
                .textFieldStyle(DefaultTextFieldStyle())
        }
    }
}

struct PickerPropertyView: View {
    @ObservedObject var property: PickerProperty
    var body: some View {
        Picker(selection: $property.selection, label: Text("Picker")) {
            ForEach(property.options, id: \.self) { option in
                Text(option.description).tag(option.description)
            }
        }
        .labelsHidden()
    }
}

struct ColorPropertyView: View {
    @ObservedObject var property: ColorProperty
    var body: some View {
        PropertyView(property: property) {
            ColorPicker("Color", selection: $property.color)
                .labelsHidden()
        }
    }
}


struct PropertiesFactory_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NumberPropertyView(property: NumberProperty())
                .padding()
                .previewLayout(.sizeThatFits)

            PickerPropertyView(property: PickerProperty(options: MathNode.Operation.allCases.map(\.description)))
        }
        .environmentObject(LinkContext())
    }
}
