//
//  AppDelegate.swift
//  NodeFlowSUI
//
//  Created by Vasilis Akoinoglou on 15/10/19.
//  Copyright © 2019 Vasilis Akoinoglou. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(LinkContext())

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        //test()
    }

    func test() {
        var cancellable: AnyCancellable?

        let graph = Graph()

        let node1 = MathNode()
        let node2 = MathNode()

        graph.addNode(node1)
        graph.addNode(node2)

        let output = NumberProperty(value: 1, isInput: false)
        let input  = NumberProperty(value: 0, isInput: true)

        let connection = Connection(output: output, input: input)

        graph.addConnection(connection)

        dump(graph)

        //cancellable = output.$value.assign(to: \.value, on: input)

        output.value = 2

        print(input.value, output.value)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

