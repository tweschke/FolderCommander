//
//  Folder_CommanderApp.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI
import AppKit

@main
struct Folder_CommanderApp: App {
    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView(appSettings: appSettings)
                .preferredColorScheme(.dark)
                .onAppear {
                    if let app = NSApp {
                        app.appearance = NSAppearance(named: .darkAqua)
                    }
                }
        }
        .defaultSize(width: 1400, height: 900)
        .windowToolbarStyle(.unified)
        .commands {
            AppMenuCommands()
        }
    }
}
