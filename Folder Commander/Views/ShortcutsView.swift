//
//  ShortcutsView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 03/02/2026.
//

import SwiftUI
import AppKit

struct ShortcutsView: View {
    @ObservedObject var appSettings: AppSettings
    @ObservedObject var templateStore: TemplateStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Shortcuts")
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Use shortcuts in template names and file content to insert project context.")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Available Tokens",
                        systemImage: "curlybraces",
                        subtitle: "Use these in names or file content"
                    )
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        TokenRow(
                            token: "{{projectName}}",
                            description: "Project root folder name"
                        )
                        TokenRow(
                            token: "{{parentName}}",
                            description: "Immediate parent folder name"
                        )
                        TokenRow(
                            token: "{{creationDate}}",
                            description: "Project creation date (e.g., 03 February 2026)"
                        )
                    }
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .padding(.horizontal, AppSpacing.lg)
                
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Examples",
                        systemImage: "lightbulb.fill",
                        subtitle: "Copy and adapt these patterns"
                    )
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ExampleRow(
                            title: "File name",
                            example: "readme - {{projectName}} - {{creationDate}}.txt"
                        )
                        ExampleRow(
                            title: "File content",
                            example: "Project: {{projectName}}\nCreated: {{creationDate}}\nFolder: {{parentName}}"
                        )
                    }
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.contentGradient)
        .standardToolbar(templateStore: templateStore, appSettings: appSettings)
    }
}

private struct TokenRow: View {
    let token: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Button(action: copyToken) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(AppColors.surfaceElevated)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copy shortcut")
            .accessibilityHint("Copies \(token) to the clipboard")
            
            Text(token)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(AppColors.textPrimary)
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .fill(AppColors.surfaceElevated)
                )
            
            Text(description)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
    
    private func copyToken() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(token, forType: .string)
    }
}

private struct ExampleRow: View {
    let title: String
    let example: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            
            Text(example)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(AppColors.textPrimary)
                .padding(AppSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
        }
    }
}

#Preview {
    ShortcutsView(appSettings: AppSettings(), templateStore: TemplateStore())
        .frame(width: 800, height: 600)
}
