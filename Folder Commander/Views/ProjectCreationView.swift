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
                VStack(spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<CreationStep.allCases.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentStep.rawValue ? AppColors.primary : AppColors.border)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(index == currentStep.rawValue ? AppColors.primary : Color.clear, lineWidth: 3)
                                        .frame(width: 20, height: 20)
                                )
                            
                            if index < CreationStep.allCases.count - 1 {
                                Rectangle()
                                    .fill(index < currentStep.rawValue ? AppColors.primary : AppColors.border)
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Text(CreationStep.allCases[currentStep.rawValue].title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.vertical, AppSpacing.lg)
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
                .padding(AppSpacing.lg)
                .background(AppColors.background)
                
                Divider()
                    .background(AppColors.border)
                
                // Navigation buttons
                HStack(spacing: AppSpacing.md) {
                    if currentStep != .selectTemplate {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                goToPreviousStep()
                            }
                        }) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                        .secondaryButton()
                    }
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                    
                    if currentStep == .preview {
                        Button(action: { createProject() }) {
                            HStack(spacing: AppSpacing.sm) {
                                if isCreating {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                Text("Create Project")
                            }
                        }
                        .primaryButton(enabled: !isCreating && !projectName.isEmpty && destinationURL != nil)
                        .disabled(isCreating || projectName.isEmpty || destinationURL == nil)
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                goToNextStep()
                            }
                        }) {
                            HStack(spacing: AppSpacing.sm) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .primaryButton(enabled: canProceedToNextStep)
                        .disabled(!canProceedToNextStep)
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppColors.secondaryBackground)
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
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 20))
                
                Text("Choose a template to use for your project:")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if templateStore.templates.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "folder.badge.minus")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(AppColors.textTertiary)
                    
                    Text("No templates available")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Please create a template first")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedTemplate) {
                    ForEach(templateStore.templates) { template in
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
                                
                                Text("\(template.rootItem.getAllItems().count) items")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, AppSpacing.xs)
                        .tag(template)
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var enterNameView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "text.cursor")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 20))
                
                Text("Enter a name for your project:")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(.plain)
                .font(AppTypography.title2)
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(
                                    projectName.isEmpty ? AppColors.border : AppColors.primary.opacity(0.5),
                                    lineWidth: 2
                                )
                        )
                )
                .appShadow(AppShadow.small)
            
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: 12))
                
                Text("This will be the name of the root folder.")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var selectLocationView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "folder.fill")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 20))
                
                Text("Choose where to create the project:")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if let url = destinationURL {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(AppColors.successGradient.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.successGradient)
                            .font(.system(size: 20))
                    }
                    
                    Text(url.path)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                .padding(AppSpacing.md)
                .cardStyle()
            } else {
                HStack {
                    Image(systemName: "folder.badge.questionmark")
                        .foregroundColor(AppColors.textTertiary)
                        .font(.system(size: 20))
                    
                    Text("No location selected")
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                )
            }
            
            Button(action: { selectDestinationFolder() }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "folder.badge.plus")
                    Text("Choose Folder...")
                }
            }
            .primaryButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var previewView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "eye.fill")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 20))
                
                Text("Preview:")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if let template = selectedTemplate {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Template")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(template.name)
                                .font(AppTypography.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Project Name")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(projectName)
                                .font(AppTypography.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        if let url = destinationURL {
                            Divider()
                                .frame(height: 30)
                            
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Location")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text(url.lastPathComponent)
                                    .font(AppTypography.bodyBold)
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(AppSpacing.lg)
                .cardStyle()
                
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundStyle(AppColors.primaryGradient)
                            .font(.system(size: 18))
                        
                        Text("Structure:")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            // Show children of rootItem directly, not rootItem itself
                            if let children = template.rootItem.children, !children.isEmpty {
                                ForEach(children) { child in
                                    TemplateTreeView(item: child)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text("No structure defined")
                                        .foregroundColor(AppColors.textSecondary)
                                        .font(AppTypography.subheadline)
                                    Spacer()
                                }
                                .padding(AppSpacing.lg)
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 300)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(AppColors.tertiaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                }
            }
            
            if isCreating {
                VStack(spacing: AppSpacing.md) {
                    ProgressView(value: creationProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(AppColors.primary)
                    
                    Text("Creating project...")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.lg)
                .cardStyle()
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
