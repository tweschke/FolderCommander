//
//  SettingsView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var templateStore: TemplateStore
    
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
            
            // Interface Section
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(AppColors.primaryGradient)
                        .font(.system(size: 18))
                    
                    Text("Interface")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("Theme")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("Dark (default)")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text("The dark dashboard palette is now the default for the entire app.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.lg)
            .dashboardCardStyle()
            .padding(.horizontal, AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.contentGradient)
        .standardToolbar(templateStore: templateStore, appSettings: settings)
        .navigationTitle("Folder Commander")
    }
}

#Preview {
    SettingsView(settings: AppSettings(), templateStore: TemplateStore())
        .frame(width: 800, height: 600)
}
