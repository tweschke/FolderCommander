//
//  SettingsView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var templateStore: TemplateStore

    @State private var showingImport = false
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var showingExportError = false
    @State private var importSuccessMessage = ""
    @State private var importErrorMessage = ""
    @State private var exportErrorMessage = ""

    @State private var showingImportConflictSheet = false
    @State private var pendingImportTemplates: [Template] = []
    @State private var pendingConflictingNames: Set<String> = []
    @State private var showRenameFieldsInConflictSheet = false
    @State private var renameValues: [UUID: String] = [:]
    @State private var renameValidationMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Backups")
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Import or export template backups")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)

                // Templates Section (Import/Export)
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "folder.fill.badge.gearshape")
                            .foregroundStyle(AppColors.primaryGradient)
                            .font(.system(size: 18))

                        Text("Templates")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Import or export all templates as a single JSON file.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)

                        HStack(spacing: AppSpacing.md) {
                            Button(action: { showingImport = true }) {
                                Label("Import Templates", systemImage: "tray.and.arrow.down")
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .help("Import templates from a JSON file")
                            .accessibilityLabel("Import templates")
                            .accessibilityHint("Opens a dialog to choose a JSON file to import")

                            Button(action: exportAllTemplates) {
                                Label("Export All Templates", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .help("Save all templates to a JSON file")
                            .disabled(templateStore.templates.isEmpty)
                            .accessibilityLabel("Export all templates")
                            .accessibilityHint("Saves all templates to a JSON file")
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.contentGradient)
        .standardToolbar(templateStore: templateStore, appSettings: settings)
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
        .alert("Export Failed", isPresented: $showingExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportErrorMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .importTemplate)) { _ in
            showingImport = true
        }
        .sheet(isPresented: $showingImportConflictSheet) {
            importConflictSheetContent
        }
    }

    @ViewBuilder
    private var importConflictSheetContent: some View {
        let existingNames = Set(templateStore.templates.map(\.name))
        let conflictingTemplates = pendingImportTemplates.filter { pendingConflictingNames.contains($0.name) }
        let namesList = pendingConflictingNames.sorted().joined(separator: ", ")

        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Template Name Conflict")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.textPrimary)

            Text("The following template name\(pendingConflictingNames.count == 1 ? "" : "s") already exist\(pendingConflictingNames.count == 1 ? "s" : ""): \(namesList). Would you like to override (replace) the existing one\(pendingConflictingNames.count == 1 ? "" : "s"), cancel the import, or rename and import?")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if showRenameFieldsInConflictSheet {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Enter new names to import without overwriting:")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    ForEach(conflictingTemplates, id: \.id) { template in
                        HStack(spacing: AppSpacing.sm) {
                            Text(template.name)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(1)
                                .frame(width: 120, alignment: .leading)
                            TextField("New name", text: Binding(
                                get: { renameValues[template.id] ?? template.name },
                                set: { renameValues[template.id] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }

                    if let msg = renameValidationMessage {
                        Text(msg)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.destructive)
                    }

                    HStack(spacing: AppSpacing.md) {
                        Button("Back") {
                            showRenameFieldsInConflictSheet = false
                            renameValidationMessage = nil
                        }
                        .buttonStyle(TertiaryButtonStyle())

                        Button("Import with New Names") {
                            applyImportWithRename(existingNames: existingNames, conflictingTemplates: conflictingTemplates)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            } else {
                HStack(spacing: AppSpacing.md) {
                    Button("Override") {
                        applyImportOverride()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Cancel") {
                        clearPendingImport()
                        showingImportConflictSheet = false
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Rename") {
                        showRenameFieldsInConflictSheet = true
                        renameValues = Dictionary(uniqueKeysWithValues: conflictingTemplates.map { ($0.id, $0.name) })
                        renameValidationMessage = nil
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(AppSpacing.xl)
        .frame(minWidth: 400)
    }

    private func clearPendingImport() {
        pendingImportTemplates = []
        pendingConflictingNames = []
        showRenameFieldsInConflictSheet = false
        renameValues = [:]
        renameValidationMessage = nil
    }

    private func applyImportOverride() {
        for template in pendingImportTemplates {
            if pendingConflictingNames.contains(template.name) {
                templateStore.deleteTemplate(named: template.name)
            }
            let newTemplate = Template(id: UUID(), name: template.name, rootItem: template.rootItem, createdDate: template.createdDate, modifiedDate: template.modifiedDate)
            templateStore.addTemplate(newTemplate)
        }
        let count = pendingImportTemplates.count
        importSuccessMessage = count == 1
            ? "Successfully imported 1 template (existing one overridden)."
            : "Successfully imported \(count) templates (existing ones overridden)."
        showingImportSuccess = true
        clearPendingImport()
        showingImportConflictSheet = false
    }

    private func applyImportWithRename(existingNames: Set<String>, conflictingTemplates: [Template]) {
        let newNames = conflictingTemplates.compactMap { renameValues[$0.id]?.trimmingCharacters(in: .whitespacesAndNewlines) }
        let trimmed = newNames.map { $0.isEmpty ? nil : $0 }
        if trimmed.contains(where: { $0 == nil }) {
            renameValidationMessage = "All names must be non-empty."
            return
        }
        let names = trimmed.compactMap { $0 }
        if Set(names).count != names.count {
            renameValidationMessage = "New names must be unique."
            return
        }
        if !Set(names).isDisjoint(with: existingNames) {
            renameValidationMessage = "A new name cannot match an existing template name."
            return
        }
        renameValidationMessage = nil

        for template in pendingImportTemplates {
            let name: String
            if pendingConflictingNames.contains(template.name), let newName = renameValues[template.id]?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty {
                name = newName
            } else {
                name = template.name
            }
            let newTemplate = Template(id: UUID(), name: name, rootItem: template.rootItem, createdDate: template.createdDate, modifiedDate: template.modifiedDate)
            templateStore.addTemplate(newTemplate)
        }
        let count = pendingImportTemplates.count
        importSuccessMessage = count == 1
            ? "Successfully imported 1 template."
            : "Successfully imported \(count) templates."
        showingImportSuccess = true
        clearPendingImport()
        showingImportConflictSheet = false
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

            let imported: [Template]
            if let list = templateStore.importTemplates(from: data) {
                imported = list
            } else if let single = templateStore.importTemplate(from: data) {
                imported = [single]
            } else {
                importErrorMessage = "The file does not contain valid template data. Please ensure you're importing a template file exported from Folder Commander."
                showingImportError = true
                return
            }

            let existingNames = Set(templateStore.templates.map(\.name))
            let importedNames = Set(imported.map(\.name))
            let conflictingNames = importedNames.intersection(existingNames)

            if conflictingNames.isEmpty {
                let addedCount = templateStore.importAndAddTemplates(from: data)
                if addedCount > 0 {
                    importSuccessMessage = addedCount == 1
                        ? "Successfully imported 1 template."
                        : "Successfully imported \(addedCount) templates."
                    showingImportSuccess = true
                } else {
                    importErrorMessage = "The file does not contain valid template data."
                    showingImportError = true
                }
            } else {
                pendingImportTemplates = imported
                pendingConflictingNames = conflictingNames
                showRenameFieldsInConflictSheet = false
                renameValues = [:]
                renameValidationMessage = nil
                showingImportConflictSheet = true
            }

        case .failure(let error):
            importErrorMessage = "Import failed: \(error.localizedDescription)"
            showingImportError = true
        }
    }

    private func exportAllTemplates() {
        guard let data = templateStore.exportAllTemplates() else {
            exportErrorMessage = "Unable to export templates."
            showingExportError = true
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "Folder Commander Templates.json"
        savePanel.canCreateDirectories = true

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try data.write(to: url)
                } catch {
                    exportErrorMessage = "Unable to save file: \(error.localizedDescription)"
                    showingExportError = true
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: AppSettings(), templateStore: TemplateStore())
        .frame(width: 800, height: 600)
}
