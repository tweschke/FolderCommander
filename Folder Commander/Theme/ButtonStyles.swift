//
//  ButtonStyles.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                Group {
                    if isEnabled {
                        AppColors.primaryGradient
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .cornerRadius(AppCornerRadius.medium)
            .appShadow(isEnabled ? AppShadow.medium : AppShadow.small)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1.0) : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textInactive)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
            .appShadow(configuration.isPressed ? AppShadow.small : AppShadow.medium)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style
struct TertiaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.bodyBold)
            .foregroundColor(isEnabled ? Color.primary : Color.secondary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1.0) : 0.5)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style
struct DestructiveButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [AppColors.destructive, AppColors.destructiveLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .cornerRadius(AppCornerRadius.medium)
            .appShadow(isEnabled ? AppShadow.medium : AppShadow.small)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1.0) : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style
struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = 44
    var color: Color = AppColors.primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.1))
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Toolbar Icon Button Style (Oval/Pill shape)
struct ToolbarIconButtonStyle: ButtonStyle {
    var isPrimary: Bool = false
    var size: CGFloat = 36
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isPrimary ? .white : AppColors.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(minWidth: size, minHeight: size)
            .background(
                Capsule()
                    .fill(
                        isPrimary 
                            ? AnyShapeStyle(AppColors.primaryGradient)
                            : AnyShapeStyle(AppColors.surfaceElevated)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                isPrimary
                                    ? Color.clear
                                    : AppColors.border,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var appPrimary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var appSecondary: SecondaryButtonStyle {
        SecondaryButtonStyle()
    }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var appTertiary: TertiaryButtonStyle {
        TertiaryButtonStyle()
    }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var appDestructive: DestructiveButtonStyle {
        DestructiveButtonStyle()
    }
}

// MARK: - View Extension for Button Styles
extension View {
    func primaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: enabled))
    }
    
    func secondaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isEnabled: enabled))
    }
    
    func tertiaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(TertiaryButtonStyle(isEnabled: enabled))
    }
    
    func destructiveButton(enabled: Bool = true) -> some View {
        self.buttonStyle(DestructiveButtonStyle(isEnabled: enabled))
    }
    
    func toolbarIconButton(isPrimary: Bool = false, size: CGFloat = 36) -> some View {
        self.buttonStyle(ToolbarIconButtonStyle(isPrimary: isPrimary, size: size))
    }
}
