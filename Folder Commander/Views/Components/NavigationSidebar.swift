//
//  NavigationSidebar.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case templates = "Templates"
    case createProject = "Create Project"
    case shortcuts = "Shortcuts"
    case settings = "Backups"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .templates:
            return "folder.fill"
        case .createProject:
            return "folder.badge.plus"
        case .shortcuts:
            return "curlybraces"
        case .settings:
            return "externaldrive.fill"
        }
    }
    
    /// Navigation items that appear at the top (main items)
    static var mainItems: [NavigationItem] {
        [.templates, .createProject]
    }
    
    /// Navigation items that appear at the bottom (settings/utilities)
    static var bottomItems: [NavigationItem] {
        [.shortcuts, .settings]
    }
}

struct NavigationSidebar: View {
    @Binding var selectedItem: NavigationItem
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Workspace", systemImage: "square.grid.2x2", compact: true)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)
            
            // Navigation items (main)
            VStack(spacing: AppSpacing.xs) {
                ForEach(NavigationItem.mainItems) { item in
                    NavigationItemView(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedItem = item
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            
            Spacer()
            
            // Navigation items (bottom - settings)
            VStack(spacing: AppSpacing.sm) {
                Divider()
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.sm)
                
                SectionHeader(title: "Settings", systemImage: "gearshape.fill", compact: true)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xs)
                
                ForEach(NavigationItem.bottomItems) { item in
                    NavigationItemView(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedItem = item
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.sidebarGradient)
        .overlay(
            Rectangle()
                .fill(AppColors.border)
                .frame(width: 1)
                .opacity(0.6),
            alignment: .trailing
        )
    }
}

struct NavigationItemView: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void
    
    private func accessibilityHint(for item: NavigationItem) -> String {
        switch item {
        case .templates:
            return "Shows your folder structure templates"
        case .createProject:
            return "Opens the project creation wizard"
        case .shortcuts:
            return "Shows available shortcut tokens"
        case .settings:
            return "Opens backup and restore tools"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColors.primaryGradient : LinearGradient(colors: [AppColors.textSecondary, AppColors.textTertiary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 24)
                
                Text(item.rawValue)
                    .font(AppTypography.bodyBold)
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(AppColors.selectedGlowGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.rawValue)
        .accessibilityHint(accessibilityHint(for: item))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationSidebar(selectedItem: .constant(.templates))
        .frame(width: 200, height: 600)
}
