//
//  ProjectCreationView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI
import AppKit

struct ProjectCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateStore: TemplateStore
    
    @State private var selectedTemplate: Template?
    @State private var projectName: String = ""
    @State private var destinationURL: URL?
    @State private var currentStep: CreationStep = .selectTemplate
    @State private var isCreating = false
    @State private var creationProgress: Double = 0
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var createdProjectURL: URL?
    
    private let fileSystemService = FileSystemService()
    
    enum CreationStep: Int, CaseIterable {
        case selectTemplate = 0
        case enterName = 1
        case selectLocation = 2
        case preview = 3
        
        var title: String {
            switch self {
            case .selectTemplate: return "Select Template"
            case .enterName: return "Enter Project Name"
            case .selectLocation: return "Select Destination"
            case .preview: return "Preview"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep.rawValue), total: Double(CreationStep.allCases.count - 1))
                    .padding()
                
                Divider()
                
                // Step content
                Group {
                    switch currentStep {
                    case .selectTemplate:
                        selectTemplateView
                    case .enterName:
                        enterNameView
                    case .selectLocation:
                        selectLocationView
                    case .preview:
                        previewView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                
                Divider()
                
                // Navigation buttons
                HStack {
                    if currentStep != .selectTemplate {
                        Button("Back") {
                            withAnimation {
                                goToPreviousStep()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    if currentStep == .preview {
                        Button("Create Project") {
                            createProject()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isCreating || projectName.isEmpty || destinationURL == nil)
                    } else {
                        Button("Next") {
                            withAnimation {
                                goToNextStep()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceedToNextStep)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Project")
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
                Button("Show in Finder") {
                    if let url = createdProjectURL {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                    }
                    dismiss()
                }
            } message: {
                Text("Project '\(projectName)' created successfully!")
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    // MARK: - Step Views
    
    private var selectTemplateView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a template to use for your project:")
                .font(.headline)
            
            if templateStore.templates.isEmpty {
                Text("No templates available. Please create a template first.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedTemplate) {
                    ForEach(templateStore.templates) { template in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline)
                            Text("\(template.rootItem.getAllItems().count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(template)
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }
    
    private var enterNameView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter a name for your project:")
                .font(.headline)
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(.roundedBorder)
                .font(.title2)
            
            Text("This will be the name of the root folder.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var selectLocationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose where to create the project:")
                .font(.headline)
            
            if let url = destinationURL {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                    Text(url.path)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            } else {
                Text("No location selected")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            }
            
            Button("Choose Folder...") {
                selectDestinationFolder()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var previewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview:")
                .font(.headline)
            
            if let template = selectedTemplate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Template: \(template.name)")
                        .font(.subheadline)
                    Text("Project Name: \(projectName)")
                        .font(.subheadline)
                    if let url = destinationURL {
                        Text("Location: \(url.path)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                Divider()
                
                Text("Structure:")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        // Show children of rootItem directly, not rootItem itself
                        if let children = template.rootItem.children, !children.isEmpty {
                            ForEach(children) { child in
                                TemplateTreeView(item: child)
                            }
                        } else {
                            Text("No structure defined")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 300)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            
            if isCreating {
                ProgressView(value: creationProgress, total: 1.0)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Navigation
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case .selectTemplate:
            return selectedTemplate != nil
        case .enterName:
            return !projectName.isEmpty
        case .selectLocation:
            return destinationURL != nil
        case .preview:
            return true
        }
    }
    
    private func goToNextStep() {
        guard canProceedToNextStep else { return }
        
        if let nextStep = CreationStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    private func goToPreviousStep() {
        if let previousStep = CreationStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    // MARK: - Actions
    
    private func selectDestinationFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.prompt = "Select"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                destinationURL = url
            }
        }
    }
    
    private func createProject() {
        guard let template = selectedTemplate,
              let destination = destinationURL else {
            return
        }
        
        isCreating = true
        creationProgress = 0
        
        Task {
            do {
                // Start accessing security-scoped resource
                let accessing = destination.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        destination.stopAccessingSecurityScopedResource()
                    }
                }
                
                let createdURL = try await fileSystemService.createProject(
                    from: template,
                    name: projectName,
                    at: destination
                )
                
                await MainActor.run {
                    createdProjectURL = createdURL
                    isCreating = false
                    creationProgress = 1.0
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    ProjectCreationView(templateStore: TemplateStore())
}
