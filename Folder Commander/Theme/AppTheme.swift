//
//  AppTheme.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI
import AppKit

// MARK: - Color Theme
struct AppColors {
    // Primary colors - purple-blue for icons and accents (kept for branding)
    static let primary = Color(red: 0.4, green: 0.25, blue: 0.7)
    static let primaryLight = Color(red: 0.55, green: 0.4, blue: 0.85)
    static let primaryDark = Color(red: 0.3, green: 0.2, blue: 0.6)
    
    // Accent colors - light blue for active states
    static let accent = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let accentLight = Color(red: 0.4, green: 0.7, blue: 1.0)
    static let accentMagenta = Color(red: 0.9, green: 0.3, blue: 0.7)
    
    // Success/Positive
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let successLight = Color(red: 0.3, green: 0.8, blue: 0.5)
    
    // Warning
    static let warning = Color(red: 1.0, green: 0.65, blue: 0.0)
    
    // Destructive
    static let destructive = Color(red: 0.9, green: 0.25, blue: 0.3)
    static let destructiveLight = Color(red: 0.95, green: 0.35, blue: 0.4)
    
    // Text - adaptive for contrast
    static let textPrimary = Color.adaptive(
        light: NSColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1),
        dark: NSColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1)
    )
    static let textSecondary = Color.adaptive(
        light: NSColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1),
        dark: NSColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1)
    )
    static let textTertiary = Color.adaptive(
        light: NSColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1),
        dark: NSColor(red: 0.65, green: 0.65, blue: 0.7, alpha: 1)
    )
    static let textInactive = Color.adaptive(
        light: NSColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1),
        dark: NSColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
    )

    // Backgrounds
    static let background = Color.adaptive(
        light: NSColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1),
        dark: NSColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
    )
    static let backgroundLight = Color.adaptive(
        light: NSColor.white,
        dark: NSColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1)
    )
    static let secondaryBackground = Color.adaptive(
        light: NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1),
        dark: NSColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1)
    )
    static let tertiaryBackground = Color.adaptive(
        light: NSColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1),
        dark: NSColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1)
    )

    // Surfaces (for cards, panels)
    static let surface = Color.adaptive(
        light: NSColor(white: 1, alpha: 0.9),
        dark: NSColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.9)
    )
    static let surfaceElevated = Color.adaptive(
        light: NSColor(white: 1, alpha: 0.95),
        dark: NSColor(red: 0.18, green: 0.18, blue: 0.23, alpha: 0.95)
    )

    // Borders
    static let border = Color.adaptive(
        light: NSColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1),
        dark: NSColor(red: 0.35, green: 0.35, blue: 0.45, alpha: 1)
    )
    static let borderLight = Color.adaptive(
        light: NSColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1),
        dark: NSColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
    )
    static let borderGlow = Color.adaptive(
        light: NSColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.3),
        dark: NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.25)
    )

    // Glow colors for selected states
    static let glowBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let glowPurple = Color(red: 0.4, green: 0.25, blue: 0.7)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [success, successLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Background gradients (adapted for both modes)
    static let sidebarGradient = LinearGradient(
        colors: [
            Color.adaptive(
                light: NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1),
                dark: NSColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1)
            ),
            Color.adaptive(
                light: NSColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1),
                dark: NSColor(red: 0.1, green: 0.1, blue: 0.14, alpha: 1)
            )
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let contentGradient = LinearGradient(
        colors: [
            Color.adaptive(
                light: NSColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1),
                dark: NSColor(red: 0.1, green: 0.1, blue: 0.14, alpha: 1)
            ),
            Color.adaptive(
                light: NSColor.white,
                dark: NSColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1)
            )
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Selected state gradient
    static let selectedGlowGradient = LinearGradient(
        colors: [
            Color.adaptive(
                light: NSColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1),
                dark: NSColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 1)
            ),
            Color.adaptive(
                light: NSColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1),
                dark: NSColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1)
            )
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Glassmorphic material
    static let glassMaterial = Material.ultraThinMaterial
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title, design: .rounded, weight: .semibold)
    static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
    static let title3 = Font.system(.title3, design: .rounded, weight: .medium)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let bodyBold = Font.system(.body, design: .rounded, weight: .semibold)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - Shadows
struct AppShadow {
    static let small = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Modifiers
extension View {
    func appShadow(_ shadow: AppShadow.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
            .appShadow(AppShadow.small)
    }
    
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.glassMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
    }
    
    func glassCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppColors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
    
    func glowEffect(intensity: CGFloat = 0.3) -> some View {
        self
            .shadow(color: AppColors.glowBlue.opacity(intensity * 0.2), radius: 8, x: 0, y: 0)
    }
}
