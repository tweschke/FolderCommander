//
//  TemplatesView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct TemplatesView: View {
    @ObservedObject var templateStore: TemplateStore
    @ObservedObject var appSettings: AppSettings
    @State private var showingNewTemplate = false
    @State private var showingImport = false
    @State private var editingTemplate: Template?
    @State private var selectedTemplate: Template?
    @State private var templateListWidth: CGFloat = 420
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importSuccessMessage = ""
    @State private var importErrorMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            let maxTemplateListWidth = geometry.size.width - 200
            
            HStack(spacing: 0) {
                // Template list
                ScrollView {
                    LazyVStack(spacing: AppSpacing.md) {
                        if templateStore.templates.isEmpty {
                            VStack(spacing: AppSpacing.lg) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primaryGradient.opacity(0.2))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "folder.badge.questionmark")
                                        .font(.system(size: 56, weight: .light))
                                        .foregroundStyle(AppColors.primaryGradient)
                                }
                                
                                VStack(spacing: AppSpacing.sm) {
                                    Text("No Templates")
                                        .font(AppTypography.title2)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Create your first template to get started")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button(action: { showingNewTemplate = true }) {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("New Template")
                                    }
                                }
                                .primaryButton()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.xl)
                        } else {
                            ForEach(templateStore.templates) { template in
                                TemplateCardView(
                                    template: template,
                                    isSelected: selectedTemplate?.id == template.id,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTemplate = template
                                        }
                                    },
                                    onEdit: {
                                        editingTemplate = template
                                    },
                                    onExport: {
                                        exportTemplate(template)
                                    },
                                    onDelete: {
                                        templateStore.deleteTemplate(template)
                                    }
                                )
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
                .scrollIndicators(.hidden) // Reduce rendering overhead
                .frame(width: templateListWidth)
                .animation(nil, value: templateListWidth) // Disable animation during resize
                .background(AppColors.contentGradient)
                
                ResizableDivider(
                    width: $templateListWidth,
                    minWidth: 280,
                    maxWidth: maxTemplateListWidth
                )
                
                // Template detail
                Group {
                    if let template = selectedTemplate {
                        TemplateDetailView(template: template, appSettings: appSettings)
                    } else {
                        VStack(spacing: AppSpacing.lg) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundStyle(AppColors.primaryGradient.opacity(0.5))
                            
                            Text("Select a template to preview")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.contentGradient)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingImport = true }) {
                    Label("Import", systemImage: "tray.and.arrow.down")
                }
                .labelStyle(.titleAndIcon)
                .help("Import templates from a JSON file")
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
            }
        }
        .sheet(isPresented: $showingNewTemplate) {
            TemplateEditorView(templateStore: templateStore, appSettings: appSettings)
        }
        .sheet(item: $editingTemplate) { template in
            TemplateEditorView(templateStore: templateStore, editingTemplate: template, appSettings: appSettings)
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
    }
    
    private func exportTemplate(_ template: Template) {
        guard let data = templateStore.exportTemplate(template) else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "\(template.name).json"
        savePanel.canCreateDirectories = true
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                try? data.write(to: url)
            }
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
            
            // Request security-scoped resource access (required for macOS file access)
            guard url.startAccessingSecurityScopedResource() else {
                importErrorMessage = "Unable to access the selected file. Please try again."
                showingImportError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Read file data
            guard let data = try? Data(contentsOf: url) else {
                importErrorMessage = "Unable to read the file. Please ensure it's a valid JSON file."
                showingImportError = true
                return
            }
            
            // Import templates (handles both single template and array formats)
            let importedCount = templateStore.importAndAddTemplates(from: data)
            
            if importedCount > 0 {
                if importedCount == 1 {
                    importSuccessMessage = "Successfully imported 1 template."
                } else {
                    importSuccessMessage = "Successfully imported \(importedCount) templates."
                }
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

struct TemplateCardView: View {
    let template: Template
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
    private var itemCount: Int {
        template.rootItem.getAllItems().count
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Card content (clickable)
            Button(action: onSelect) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(AppColors.primaryGradient.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "folder.fill")
                            .foregroundStyle(AppColors.primaryGradient)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(template.name)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: AppSpacing.sm) {
                            Text(template.modifiedDate, style: .date)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            if itemCount > 0 {
                                Text("•")
                                    .foregroundColor(AppColors.textTertiary)
                                
                                Text("\(itemCount) items")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            // Action buttons
            HStack(spacing: AppSpacing.sm) {
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .medium))
                }
                .toolbarIconButton(isPrimary: false, size: 28)
                .help("Edit")
                
                // Export button
                Button(action: onExport) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                }
                .toolbarIconButton(isPrimary: false, size: 28)
                .help("Export")
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(DeleteIconButtonStyle())
                .help("Delete")
            }
        }
        .padding(AppSpacing.md)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.selectedGlowGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.accent.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }
            }
        )
    }
}

// MARK: - Delete Icon Button Style
struct DeleteIconButtonStyle: ButtonStyle {
    var size: CGFloat = 28
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.destructive,
                                AppColors.destructiveLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(
                color: AppColors.destructive.opacity(0.2),
                radius: 4,
                x: 0,
                y: 2
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    TemplatesView(templateStore: TemplateStore(), appSettings: AppSettings())
        .frame(width: 800, height: 600)
}
