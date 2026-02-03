//
//  SectionHeader.swift
//  Folder Commander
//
//  Created by GPT on 03/02/2026.
//

import SwiftUI

struct IconChip: View {
    let systemName: String
    var size: CGFloat = 22
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.primaryGradient)
                .overlay(
                    Circle()
                        .stroke(AppColors.borderLight.opacity(0.7), lineWidth: 1)
                )
            
            Image(systemName: systemName)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    var subtitle: String? = nil
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: compact ? AppSpacing.sm : AppSpacing.md) {
            IconChip(systemName: systemImage, size: compact ? 18 : 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(compact ? AppTypography.caption : AppTypography.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .textCase(compact ? .uppercase : nil)
                
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, compact ? 0 : 4)
    }
}
