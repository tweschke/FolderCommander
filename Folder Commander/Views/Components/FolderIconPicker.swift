//
//  FolderIconPicker.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI

struct FolderIconPicker: View {
    @Binding var selectedIconName: String?
    @State private var searchText: String = ""
    @State private var showingIconBrowser = false
    
    // Helper function to remove .fill suffix for display purposes
    private func displayName(for iconName: String) -> String {
        if iconName.hasSuffix(".fill") {
            return String(iconName.dropLast(5)) // Remove ".fill" (5 characters)
        }
        return iconName
    }
    
    // Curated list of popular SF Symbols organized by category
    private let iconCategories: [(name: String, icons: [String])] = [
        ("Folders", [
            "folder.fill", "folder.badge.plus", "folder.badge.minus",
            "folder.badge.questionmark", "folder.badge.gearshape"
        ]),
        ("Documents", [
            "doc.fill", "doc.text.fill", "doc.richtext.fill",
            "doc.on.doc.fill", "doc.on.clipboard.fill", "doc.badge.plus"
        ]),
        ("Media", [
            "photo.fill", "photo.on.rectangle", "camera.fill",
            "video.fill", "music.note", "film.fill"
        ]),
        ("Code", [
            "chevron.left.forwardslash.chevron.right", "curlybraces",
            "number", "textformat", "terminal.fill"
        ]),
        ("Design", [
            "paintbrush.fill", "paintpalette.fill", "pencil",
            "pencil.and.outline", "scribble"
        ]),
        ("Development", [
            "hammer.fill", "wrench.and.screwdriver.fill",
            "gearshape.fill", "gearshape.2.fill", "slider.horizontal.3"
        ]),
        ("Communication", [
            "envelope.fill", "message.fill", "bubble.left.and.bubble.right.fill",
            "phone.fill", "video.bubble.left.fill"
        ]),
        ("Storage", [
            "externaldrive.fill", "internaldrive", "opticaldiscdrive.fill",
            "icloud.fill", "externaldrive.badge.icloud"
        ]),
        ("Security", [
            "lock.fill", "lock.shield.fill", "key.fill",
            "hand.raised.fill", "eye.fill"
        ]),
        ("Common", [
            "star.fill", "heart.fill", "bookmark.fill",
            "tag.fill", "flag.fill", "bell.fill"
        ])
    ]
    
    private var filteredIcons: [(name: String, icons: [String])] {
        if searchText.isEmpty {
            return iconCategories
        }
        
        let searchLower = searchText.lowercased()
        return iconCategories.compactMap { category in
            let filtered = category.icons.filter { icon in
                icon.lowercased().contains(searchLower)
            }
            return filtered.isEmpty ? nil : (name: category.name, icons: filtered)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Folder Icon")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            
            // Current icon preview
            HStack(spacing: AppSpacing.md) {
                if let iconName = selectedIconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.primaryGradient)
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 32, height: 32)
                }
                
                Text(displayName(for: selectedIconName ?? "Default"))
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
            
            // Browse and Clear buttons arranged horizontally
            HStack(spacing: AppSpacing.md) {
                // Clear button (only show if icon is selected)
                if selectedIconName != nil {
                    Button(action: {
                        selectedIconName = nil
                    }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Clear Icon")
                                .font(AppTypography.body)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryButton()
                }
                
                // Browse button
                Button(action: {
                    showingIconBrowser = true
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: selectedIconName != nil ? "pencil.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 16))
                        Text(selectedIconName != nil ? "Change Icon" : "Select Icon")
                            .font(AppTypography.body)
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryButton()
            }
        }
        .sheet(isPresented: $showingIconBrowser) {
            IconBrowserSheet(
                selectedIconName: $selectedIconName,
                searchText: $searchText,
                filteredIcons: filteredIcons
            )
        }
    }
}

struct IconBrowserSheet: View {
    @Binding var selectedIconName: String?
    @Binding var searchText: String
    let filteredIcons: [(name: String, icons: [String])]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Search icons...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .padding(AppSpacing.lg)
                
                Divider()
                    .background(AppColors.border)
                
                // Icon grid
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppSpacing.lg) {
                        ForEach(filteredIcons, id: \.name) { category in
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text(category.name)
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, AppSpacing.md)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 80), spacing: AppSpacing.sm)
                                ], spacing: AppSpacing.sm) {
                                    ForEach(category.icons, id: \.self) { iconName in
                                        IconOptionButton(
                                            iconName: iconName,
                                            isSelected: selectedIconName == iconName
                                        ) {
                                            selectedIconName = iconName
                                        }
                                    }
                                }
                                .padding(.horizontal, AppSpacing.md)
                            }
                        }
                    }
                    .padding(.vertical, AppSpacing.md)
                }
                .background(AppColors.contentGradient)
            }
            .background(AppColors.background)
            .navigationTitle("Select Icon")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                    .toolbarItemCentered()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .primaryButton()
                    .toolbarItemCentered()
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct IconOptionButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    // Helper function to remove .fill suffix for display purposes
    private func displayName(for iconName: String) -> String {
        if iconName.hasSuffix(".fill") {
            return String(iconName.dropLast(5)) // Remove ".fill" (5 characters)
        }
        return iconName
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        isSelected
                            ? AppColors.primaryGradient
                            : LinearGradient(
                                colors: [AppColors.textPrimary, AppColors.textSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(
                                isSelected
                                    ? AppColors.primary.opacity(0.1)
                                    : AppColors.surfaceElevated
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                    .stroke(
                                        isSelected ? AppColors.accent : AppColors.border,
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                    )
                    .shadow(
                        color: isSelected ? AppColors.accent.opacity(0.2) : Color.clear,
                        radius: isSelected ? 4 : 0
                    )
                
                Text(displayName(for: iconName))
                    .font(AppTypography.caption)
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 80)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FolderIconPicker(selectedIconName: .constant(nil))
        .padding()
}
