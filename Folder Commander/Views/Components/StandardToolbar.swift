//
//  StandardToolbar.swift
//  Folder Commander
//
//  Created by GPT on 28/01/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct StandardToolbar: ViewModifier {
    @ObservedObject var templateStore: TemplateStore
    @ObservedObject var appSettings: AppSettings

    @State private var showingNewTemplate = false
    @State private var showingImport = false
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importSuccessMessage = ""
    @State private var importErrorMessage = ""

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingImport = true }) {
                        Label("Import", systemImage: "tray.and.arrow.down")
                    }
                    .labelStyle(.titleAndIcon)
                    .help("Import templates from a JSON file")
                    .accessibilityLabel("Import template")
                    .accessibilityHint("Opens a file picker to import templates from a JSON file")
                }

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
            .fileImporter(
                isPresented: $showingImport,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert("Import Successful", isPresented: $showingImportSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importSuccessMessage)
            }
            .alert("Import Failed", isPresented: $showingImportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importErrorMessage)
            }
            .onReceive(NotificationCenter.default.publisher(for: .importTemplate)) { _ in
                showingImport = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .exportTemplate)) { _ in
                // Export will be handled by TemplatesView when a template is selected
                // This notification can trigger export if there's a selected template
            }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                importErrorMessage = "No file was selected."
                showingImportError = true
                return
            }

            guard url.startAccessingSecurityScopedResource() else {
                importErrorMessage = "Unable to access the selected file. Please try again."
                showingImportError = true
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }

            guard let data = try? Data(contentsOf: url) else {
                importErrorMessage = "Unable to read the file. Please ensure it's a valid JSON file."
                showingImportError = true
                return
            }

            let importedCount = templateStore.importAndAddTemplates(from: data)

            if importedCount > 0 {
                importSuccessMessage = importedCount == 1
                    ? "Successfully imported 1 template."
                    : "Successfully imported \(importedCount) templates."
                showingImportSuccess = true
            } else {
                importErrorMessage = "The file does not contain valid template data. Please ensure you're importing a template file exported from Folder Commander."
                showingImportError = true
            }

        case .failure(let error):
            importErrorMessage = "Import failed: \(error.localizedDescription)"
            showingImportError = true
        }
    }
}

extension View {
    func standardToolbar(templateStore: TemplateStore, appSettings: AppSettings) -> some View {
        modifier(StandardToolbar(templateStore: templateStore, appSettings: appSettings))
    }
}
