//
//  ContentView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var appSettings: AppSettings

    var body: some View {
        MainView(appSettings: appSettings)
            .background(WindowTitleRemover())
    }
}

// View modifier to remove window title text
struct WindowTitleRemover: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.title = ""
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.title = ""
            }
        }
    }
}

#Preview {
    ContentView(appSettings: AppSettings())
}
