//
//  MainView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @StateObject private var templateStore = TemplateStore()
    @State private var showingNewTemplate = false
    @State private var showingCreateProject = false
    @State private var showingImport = false
    @State private var editingTemplate: Template?
    @State private var selectedTemplate: Template?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // First Column: Navigation/Actions
            VStack(spacing: 0) {
                // Action buttons - stacked vertically
                VStack(spacing: AppSpacing.md) {
                    Button(action: { showingNewTemplate = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                            Text("New Template")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    
                    Button(action: { showingCreateProject = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "folder.badge.plus")
                            Text("Create Project")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryButton(enabled: !templateStore.templates.isEmpty)
                    .disabled(templateStore.templates.isEmpty)
                    
                    Button(action: { showingImport = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryButton()
                }
                .padding(AppSpacing.lg)
                .background(
                    Rectangle()
                        .fill(AppColors.secondaryBackground)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.05), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                )
                
                Divider()
                    .background(AppColors.border)
                
                Spacer()
            }
            .background(AppColors.background)
            .frame(minWidth: 180)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        withAnimation {
                            // Toggle navigation column: hide it if all visible, show it if hidden
                            if columnVisibility == .all {
                                columnVisibility = .doubleColumn
                            } else {
                                columnVisibility = .all
                            }
                        }
                    }) {
                        Image(systemName: columnVisibility == .all ? "sidebar.left" : "sidebar.squares.left")
                    }
                    .help("Toggle Navigation")
                }
            }
        } content: {
            // Second Column: Template List
            NavigationStack {
                Group {
                    if templateStore.templates.isEmpty {
                        VStack(spacing: AppSpacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primaryGradient.opacity(0.1))
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppSpacing.xl)
                        .background(AppColors.background)
                    } else {
                        List(selection: $selectedTemplate) {
                            ForEach(templateStore.templates) { template in
                                TemplateRowView(template: template)
                                    .tag(template)
                                    .listRowBackground(
                                        selectedTemplate?.id == template.id
                                            ? AppColors.primary.opacity(0.1)
                                            : Color.clear
                                    )
                                    .contextMenu {
                                        Button(action: { editingTemplate = template }) {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        Button(action: { exportTemplate(template) }) {
                                            Label("Export", systemImage: "square.and.arrow.up")
                                        }
                                        Divider()
                                        Button(role: .destructive, action: { templateStore.deleteTemplate(template) }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                            .onDelete { indexSet in
                                templateStore.deleteTemplate(at: indexSet)
                            }
                        }
                        .listStyle(.sidebar)
                        .scrollContentBackground(.hidden)
                        .background(AppColors.background)
                    }
                }
            }
        } detail: {
            // Third Column: Template Preview
            NavigationStack {
                Group {
                    if let template = selectedTemplate {
                        TemplateDetailView(template: template)
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
                        .background(AppColors.background)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewTemplate) {
            TemplateEditorView(templateStore: templateStore)
        }
        .sheet(item: $editingTemplate) { template in
            TemplateEditorView(templateStore: templateStore, editingTemplate: template)
        }
        .sheet(isPresented: $showingCreateProject) {
            ProjectCreationView(templateStore: templateStore)
        }
        .fileImporter(
            isPresented: $showingImport,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
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
            guard let url = urls.first else { return }
            if let data = try? Data(contentsOf: url) {
                let _ = templateStore.importAndAddTemplates(from: data)
                // Could show an alert here with import result
            }
        case .failure:
            break
        }
    }
}

struct TemplateRowView: View {
    let template: Template
    
    private var itemCount: Int {
        template.rootItem.getAllItems().count
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(AppColors.primaryGradient.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "folder.fill")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(template.name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
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
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
    }
}

struct TemplateDetailView: View {
    let template: Template
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header Card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.primaryGradient.opacity(0.2))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "folder.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.primaryGradient)
                        }
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(template.name)
                                .font(AppTypography.largeTitle)
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: AppSpacing.md) {
                                Text(template.createdDate, style: .date)
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text("•")
                                    .foregroundColor(AppColors.textTertiary)
                                
                                Text(template.modifiedDate, style: .date)
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(AppSpacing.lg)
                .cardStyle()
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                
                // Structure Preview
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundStyle(AppColors.primaryGradient)
                            .font(.system(size: 18))
                        
                        Text("Structure Preview")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Show children of rootItem directly, not rootItem itself
                    if let children = template.rootItem.children, !children.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            ForEach(children) { child in
                                TemplateTreeView(item: child)
                                    .padding(.horizontal, AppSpacing.lg)
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            VStack(spacing: AppSpacing.sm) {
                                Image(systemName: "folder.badge.minus")
                                    .font(.system(size: 48, weight: .ultraLight))
                                    .foregroundStyle(AppColors.textTertiary)
                                
                                Text("No structure defined")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(AppSpacing.xl)
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background)
    }
}

#Preview {
    MainView()
}
