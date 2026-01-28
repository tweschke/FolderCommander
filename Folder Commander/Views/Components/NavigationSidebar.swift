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
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .templates:
            return "folder.fill"
        case .createProject:
            return "folder.badge.plus"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    /// Navigation items that appear at the top (main items)
    static var mainItems: [NavigationItem] {
        [.templates, .createProject]
    }
    
    /// Navigation items that appear at the bottom (settings/utilities)
    static var bottomItems: [NavigationItem] {
        [.settings]
    }
}

struct NavigationSidebar: View {
    @Binding var selectedItem: NavigationItem
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation items (main)
            VStack(spacing: AppSpacing.sm) {
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
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.lg)
            
            Spacer()
            
            // Navigation items (bottom - settings)
            VStack(spacing: AppSpacing.sm) {
                Divider()
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                
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
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.sidebarGradient)
    }
}

struct NavigationItemView: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isSelected ? AppColors.primaryGradient : LinearGradient(colors: [AppColors.textSecondary, AppColors.textTertiary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 24)
                
                Text(item.rawValue)
                    .font(AppTypography.headline)
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
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
    }
}

#Preview {
    NavigationSidebar(selectedItem: .constant(.templates))
        .frame(width: 200, height: 600)
}
