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
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Header with action buttons
                HStack {
                    Button(action: { showingNewTemplate = true }) {
                        Label("New Template", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: { showingCreateProject = true }) {
                        Label("Create Project", systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.bordered)
                    .disabled(templateStore.templates.isEmpty)
                    
                    Button(action: { showingImport = true }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Template list
                if templateStore.templates.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("No Templates")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Create your first template to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("New Template") {
                            showingNewTemplate = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedTemplate) {
                        ForEach(templateStore.templates) { template in
                            TemplateRowView(template: template)
                                .tag(template)
                                .contextMenu {
                                    Button("Edit") {
                                        editingTemplate = template
                                    }
                                    Button("Export") {
                                        exportTemplate(template)
                                    }
                                    Divider()
                                    Button("Delete", role: .destructive) {
                                        templateStore.deleteTemplate(template)
                                    }
                                }
                        }
                        .onDelete { indexSet in
                            templateStore.deleteTemplate(at: indexSet)
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
        } detail: {
            if let template = selectedTemplate {
                TemplateDetailView(template: template)
            } else {
                Text("Select a template to preview")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(.headline)
            Text("Modified: \(template.modifiedDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct TemplateDetailView: View {
    let template: Template
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Created: \(template.createdDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Modified: \(template.modifiedDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Divider()
                
                Text("Structure Preview")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Show children of rootItem directly, not rootItem itself
                if let children = template.rootItem.children, !children.isEmpty {
                    ForEach(children) { child in
                        TemplateTreeView(item: child)
                            .padding(.horizontal)
                    }
                } else {
                    Text("No structure defined")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    MainView()
}
