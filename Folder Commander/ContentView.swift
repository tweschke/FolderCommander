//
//  ContentView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appSettings: AppSettings

    var body: some View {
        MainView(appSettings: appSettings)
    }
}

#Preview {
    ContentView(appSettings: AppSettings())
}
