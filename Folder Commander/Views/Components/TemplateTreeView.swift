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
    let level: Int
    
    private let disclosureIndicatorWidth: CGFloat = 12
    
    // Apple's default folder blue color (matches FolderColorPicker)
    private static let appleFolderBlue = Color(red: 0.33, green: 0.67, blue: 0.95)
    
    init(item: FolderItem, appSettings: AppSettings? = nil, level: Int = 0) {
        self.item = item
        self.appSettings = appSettings
        self.level = level
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            treeRow
                .padding(.leading, CGFloat(level) * AppSpacing.md)

            if item.type == .folder, isExpanded, let children = item.children, !children.isEmpty {
                ForEach(children) { child in
                    TemplateTreeView(item: child, appSettings: appSettings, level: level + 1)
                }
            }
        }
    }
    
    private var treeRow: some View {
        HStack(spacing: AppSpacing.sm) {
            disclosureIndicator
            rowContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var disclosureIndicator: some View {
        if item.type == .folder {
            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(width: disclosureIndicatorWidth, alignment: .center)
        } else {
            Color.clear
                .frame(width: disclosureIndicatorWidth, height: 1)
        }
    }
    
    private var rowContent: some View {
        HStack(spacing: AppSpacing.sm) {
            rowIcon
            Text(item.name)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    @ViewBuilder
    private var rowIcon: some View {
        if item.type == .folder {
            let iconName = item.getIconName() ?? (isExpanded ? "folder.fill" : "folder")
            Image(systemName: iconName)
                .foregroundStyle(
                    item.color != nil
                        ? AnyShapeStyle(item.getColor() ?? Self.appleFolderBlue)
                        : AnyShapeStyle(Self.appleFolderBlue)
                )
                .font(.system(size: 18, weight: .semibold))
        } else {
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
