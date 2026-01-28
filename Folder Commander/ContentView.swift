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
            .frame(minWidth: 1200, minHeight: 800)
    }
}

#Preview {
    ContentView(appSettings: AppSettings())
}
