//
//  NodeFlowApp.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@main
struct NodeFlowApp: App {

    let graph = Graph.testGraph

    var body: some Scene {
        WindowGroup {
            ContentView(graph: graph)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            EditCommands(selectionContext: graph.selectionContext)
        }

        Settings {
            Color.red
        }
    }
}

struct EditCommands: Commands {

    @ObservedObject var selectionContext: SelectionContext

    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
            Button("Delete") {
                selectionContext.selectedNodes.forEach {
                    $0.graph?.removeNode($0)
                }
            }
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(!selectionContext.hasSelection)

            Button("Select All") {
                selectionContext.selectedNodes = selectionContext.graph?.nodes ?? []
            }
            .keyboardShortcut("a")
        }
    }
}

struct FocusedMessageKey : FocusedValueKey {
    typealias Value = Binding<SelectionContext>
}
extension FocusedValues {
    var selectionContext: FocusedMessageKey.Value? {
        get { self[FocusedMessageKey.self] }
        set { self[FocusedMessageKey.self] = newValue }
    }
}
