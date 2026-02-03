//
//  StandardToolbar.swift
//  Folder Commander
//
//  Created by GPT on 28/01/2026.
//

import SwiftUI

struct StandardToolbar: ViewModifier {
    @ObservedObject var templateStore: TemplateStore
    @ObservedObject var appSettings: AppSettings

    @State private var showingNewTemplate = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewTemplate = true }) {
                        Label {
                            Text("New Template")
                        } icon: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(AppColors.primaryGradient)
                                )
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .help("Create a new template")
                    .accessibilityLabel("New template")
                    .accessibilityHint("Opens the template editor to create a new folder structure template")
                }
            }
            .sheet(isPresented: $showingNewTemplate) {
                TemplateEditorView(templateStore: templateStore, appSettings: appSettings)
            }
    }
}

extension View {
    func standardToolbar(templateStore: TemplateStore, appSettings: AppSettings) -> some View {
        modifier(StandardToolbar(templateStore: templateStore, appSettings: appSettings))
    }
}
