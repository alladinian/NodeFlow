//
//  NumberPropertyView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 17/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct NumberPropertyView: View {
    @Binding var number: String

    var body: some View {
        TextField("0", text: $number)
            .frame(maxWidth: 100)
            .textFieldStyle(DefaultTextFieldStyle())
    }
}

struct NumberPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        NumberPropertyView(number: .constant("1.0"))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
