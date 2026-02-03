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
    @State private var editingTemplate: Template?
    @State private var selectedTemplate: Template?
    @State private var templateListWidth: CGFloat = 420
    
    var body: some View {
        GeometryReader { geometry in
            let maxTemplateListWidth = geometry.size.width - 200
            
            HStack(spacing: AppSpacing.lg) {
                // Template list
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Templates",
                        systemImage: "square.grid.2x2",
                        subtitle: "\(templateStore.templates.count) templates"
                    )
                    
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.lg) {
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
                                    
                                    Text("Use the toolbar above to create a new template.")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
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
                        .padding(.vertical, AppSpacing.sm)
                    }
                    .scrollIndicators(.hidden) // Reduce rendering overhead
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .frame(width: templateListWidth)
                .animation(nil, value: templateListWidth) // Disable animation during resize
                
                ResizableDivider(
                    width: $templateListWidth,
                    minWidth: 280,
                    maxWidth: maxTemplateListWidth
                )
                
                // Template detail
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Preview",
                        systemImage: "eye.fill",
                        subtitle: selectedTemplate?.name ?? "Select a template"
                    )
                    
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
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.lg)
        }
        .navigationTitle("Templates")
        .standardToolbar(templateStore: templateStore, appSettings: appSettings)
        .sheet(item: $editingTemplate) { template in
            TemplateEditorView(templateStore: templateStore, editingTemplate: template, appSettings: appSettings)
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
            .accessibilityLabel("Template \(template.name)")
            .accessibilityHint("Double-click to preview template structure")
            .accessibilityValue("\(itemCount) items, modified \(template.modifiedDate, style: .date)")
            
            // Action buttons
            HStack(spacing: AppSpacing.sm) {
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .medium))
                }
                .toolbarIconButton(isPrimary: false, size: 28)
                .help("Edit")
                .accessibilityLabel("Edit template \(template.name)")
                .accessibilityHint("Opens the template editor")
                
                // Export button
                Button(action: onExport) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                }
                .toolbarIconButton(isPrimary: false, size: 28)
                .help("Export")
                .accessibilityLabel("Export template \(template.name)")
                .accessibilityHint("Saves the template as a JSON file")
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(DeleteIconButtonStyle())
                .help("Delete")
                .accessibilityLabel("Delete template \(template.name)")
                .accessibilityHint("Permanently removes this template")
            }
        }
        .padding(AppSpacing.md)
        .dashboardCardStyle(isSelected: isSelected)
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
