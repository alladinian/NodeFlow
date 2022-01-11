//
//  NodesApp.swift
//  Nodes
//
//  Created by Vasilis Akoinoglou on 3/1/22.
//

import SwiftUI

let f = NodeProperty()

@main
struct NodesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
