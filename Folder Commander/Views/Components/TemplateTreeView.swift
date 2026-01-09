//
//  TemplateTreeView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct TemplateTreeView: View {
    let item: FolderItem
    @State private var isExpanded: Bool = true
    
    var body: some View {
        if item.type == .folder {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let children = item.children, !children.isEmpty {
                    ForEach(children) { child in
                        TemplateTreeView(item: child)
                            .padding(.leading, AppSpacing.lg)
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: isExpanded ? "folder.fill" : "folder")
                        .foregroundStyle(AppColors.primaryGradient)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(item.name)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.vertical, AppSpacing.xs)
            }
        } else {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.textSecondary, AppColors.textTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 16, weight: .medium))
                
                Text(item.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.leading, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
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
