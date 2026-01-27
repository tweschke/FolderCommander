//
//  SettingsView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Settings")
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Customize your Folder Commander experience")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
            
            // Appearance Section
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "circle.lefthalf.fill")
                        .foregroundStyle(AppColors.primaryGradient)
                        .font(.system(size: 18))
                    
                    Text("Appearance")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Theme")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Choose between light, dark, or follow the system setting.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Picker("Theme", selection: Binding(
                        get: { settings.themePreference },
                        set: { settings.setThemePreference($0) }
                    )) {
                        ForEach(ThemePreference.allCases) { preference in
                            Label(preference.label, systemImage: iconName(for: preference))
                                .tag(preference)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
            }
            .glassCardStyle()
            .padding(.horizontal, AppSpacing.lg)
                
                // Custom Colors Section
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "paintpalette.fill")
                            .foregroundStyle(AppColors.primaryGradient)
                            .font(.system(size: 18))
                        
                        Text("Custom Folder Colors")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        // Enable toggle
                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Enable Custom Colors")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Allow custom colors for folders in templates")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { settings.customColorsEnabled },
                                set: { settings.setCustomColorsEnabled($0) }
                            ))
                            .toggleStyle(.switch)
                            .tint(AppColors.accent)
                        }
                        .padding(AppSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        )
                        
                        // Default color picker (only shown when enabled)
                        if settings.customColorsEnabled {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Default Folder Color")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("This color will be used for folders that don't have a custom color assigned")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                FolderColorPicker(
                                    selectedColorHex: Binding(
                                        get: { settings.defaultFolderColor },
                                        set: { settings.setDefaultFolderColor($0) }
                                    ),
                                    defaultColorHex: nil
                                )
                            }
                            .padding(AppSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .fill(AppColors.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
                .glassCardStyle()
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.contentGradient)
    }
}

private extension SettingsView {
    func iconName(for preference: ThemePreference) -> String {
        switch preference {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gearshape.fill"
        }
    }
}

#Preview {
    SettingsView(settings: AppSettings())
        .frame(width: 800, height: 600)
}
