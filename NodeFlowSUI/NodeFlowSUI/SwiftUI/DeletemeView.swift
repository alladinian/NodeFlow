//
//  DeletemeView.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 9/1/22.
//  Copyright © 2022 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct DeletemeView: View {
    var body: some View {
        HStack {
            VStack {
                Circle().fill(Color.yellow)

                HStack {
                    Circle().fill(Color.yellow)

                    Circle().fill(Color.yellow)

                }
            }.focusable()

            Rectangle().fill(Color.red)

            Circle().fill(Color.green)
                .focusable()

        }
        .padding(20)
        .frame(width: 300, height: 100)
    }
}

struct DeletemeView_Previews: PreviewProvider {
    static var previews: some View {
        DeletemeView()
    }
}
