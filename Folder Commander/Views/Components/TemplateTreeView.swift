//
//  TemplateTreeView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct TemplateTreeView: View {
    let item: FolderItem
    let appSettings: AppSettings?
    @State private var isExpanded: Bool = true
    
    init(item: FolderItem, appSettings: AppSettings? = nil) {
        self.item = item
        self.appSettings = appSettings
    }
    
    var body: some View {
        if item.type == .folder {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let children = item.children, !children.isEmpty {
                    ForEach(children) { child in
                        TemplateTreeView(item: child, appSettings: appSettings)
                            .padding(.leading, AppSpacing.lg)
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    // Use custom icon if available, otherwise use default folder icon
                    let iconName = item.getIconName() ?? (isExpanded ? "folder.fill" : "folder")
                    Image(systemName: iconName)
                        .foregroundStyle(
                            appSettings?.customColorsEnabled == true
                                ? AnyShapeStyle(item.getDisplayColor(defaultColor: appSettings?.defaultFolderColor))
                                : AnyShapeStyle(AppColors.primaryGradient)
                        )
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(item.name)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.vertical, AppSpacing.sm)
            }
            .tint(AppColors.textPrimary)
        } else {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppColors.textSecondary,
                                AppColors.textTertiary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 18, weight: .semibold))
                
                Text(item.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.leading, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
        }
    }
}

#Preview {
    TemplateTreeView(item: FolderItem.folder(name: "Project", children: [
        .folder(name: "Code", children: [
            .file(name: "main.swift"),
            .folder(name: "src", children: [])
        ]),
        .file(name: "README.md")
    ]))
    .padding()
}
