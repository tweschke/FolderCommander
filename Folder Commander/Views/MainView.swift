//
//  MainView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct MainView: View {
    @StateObject private var templateStore = TemplateStore()
    @State private var selectedNavigationItem: NavigationItem = .templates
    @State private var showingCreateProject = false
    @State private var sidebarWidth: CGFloat = 220
    
    var body: some View {
        GeometryReader { geometry in
            let maxSidebarWidth = geometry.size.width * 0.4
            
            HStack(spacing: 0) {
                // Left sidebar: Navigation
                NavigationSidebar(selectedItem: $selectedNavigationItem)
                    .frame(width: sidebarWidth)
                    .animation(nil, value: sidebarWidth) // Disable animation during resize
                
                ResizableDivider(
                    width: $sidebarWidth,
                    minWidth: 180,
                    maxWidth: maxSidebarWidth
                )
                
                // Right content area: Dynamic content based on selection
                NavigationStack {
                    Group {
                        switch selectedNavigationItem {
                        case .templates:
                            TemplatesView(templateStore: templateStore)
                        case .createProject:
                            ProjectCreationView(templateStore: templateStore)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.contentGradient)
            }
        }
        .background(AppColors.background)
        .sheet(isPresented: $showingCreateProject) {
            ProjectCreationView(templateStore: templateStore)
        }
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
                .glassCardStyle()
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
        .background(AppColors.contentGradient)
    }
}

#Preview {
    MainView()
}
