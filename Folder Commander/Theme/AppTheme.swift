//
//  AppTheme.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

// MARK: - Design Palette
struct AppPalette {
    fileprivate static func color(_ hex: String, fallback: Color = .black) -> Color {
        Color(hex: hex) ?? fallback
    }

    struct Brand {
        static let primary = AppPalette.color("#4B6CFF")
        static let primaryLight = AppPalette.color("#6D8CFF")
        static let primaryDark = AppPalette.color("#324CCB")
        static let accent = AppPalette.color("#3B82FF")
        static let accentLight = AppPalette.color("#5B9BFF")
        static let accentMagenta = AppPalette.color("#C85DF8")
    }

    struct Status {
        static let success = AppPalette.color("#32C46D")
        static let successLight = AppPalette.color("#4EDB86")
        static let warning = AppPalette.color("#F4A732")
        static let destructive = AppPalette.color("#E4555E")
        static let destructiveLight = AppPalette.color("#F06A73")
    }

    struct Dark {
        static let textPrimary = AppPalette.color("#F5F7FA")
        static let textSecondary = AppPalette.color("#C3CAD6")
        static let textTertiary = AppPalette.color("#9BA3B2")
        static let textInactive = AppPalette.color("#6C7482")
        
        static let background = AppPalette.color("#0D0F12")
        static let backgroundLight = AppPalette.color("#12151A")
        static let secondaryBackground = AppPalette.color("#15181E")
        static let tertiaryBackground = AppPalette.color("#1B1E25")
        
        static let surface = AppPalette.color("#181B21")
        static let surfaceElevated = AppPalette.color("#1E2229")
        
        static let border = AppPalette.color("#2A2F38")
        static let borderLight = AppPalette.color("#343B46")
        static let borderGlow = AppPalette.color("#2D3E63")
    }
}

// MARK: - Color Theme
struct AppColors {
    // Primary colors - align with dashboard aesthetic
    static let primary = AppPalette.Brand.primary
    static let primaryLight = AppPalette.Brand.primaryLight
    static let primaryDark = AppPalette.Brand.primaryDark
    
    // Accent colors - active/interactive
    static let accent = AppPalette.Brand.accent
    static let accentLight = AppPalette.Brand.accentLight
    static let accentMagenta = AppPalette.Brand.accentMagenta
    
    // Success/Positive
    static let success = AppPalette.Status.success
    static let successLight = AppPalette.Status.successLight
    
    // Warning
    static let warning = AppPalette.Status.warning
    
    // Destructive
    static let destructive = AppPalette.Status.destructive
    static let destructiveLight = AppPalette.Status.destructiveLight
    
    // Text
    static let textPrimary = AppPalette.Dark.textPrimary
    static let textSecondary = AppPalette.Dark.textSecondary
    static let textTertiary = AppPalette.Dark.textTertiary
    static let textInactive = AppPalette.Dark.textInactive

    // Backgrounds
    static let background = AppPalette.Dark.background
    static let backgroundLight = AppPalette.Dark.backgroundLight
    static let secondaryBackground = AppPalette.Dark.secondaryBackground
    static let tertiaryBackground = AppPalette.Dark.tertiaryBackground

    // Surfaces (for cards, panels)
    static let surface = AppPalette.Dark.surface.opacity(0.96)
    static let surfaceElevated = AppPalette.Dark.surfaceElevated.opacity(0.98)

    // Borders
    static let border = AppPalette.Dark.border
    static let borderLight = AppPalette.Dark.borderLight
    static let borderGlow = AppPalette.Dark.borderGlow.opacity(0.35)

    // Glow colors for selected states
    static let glowBlue = AppPalette.Brand.accent
    static let glowPurple = AppPalette.Brand.primary
    
    // Card gradients
    static let cardGradient = LinearGradient(
        colors: [surfaceElevated, surface],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

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

    // Background gradients
    static let sidebarGradient = LinearGradient(
        colors: [
            AppPalette.Dark.secondaryBackground,
            AppPalette.Dark.background
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let contentGradient = LinearGradient(
        colors: [
            AppPalette.Dark.background,
            AppPalette.Dark.backgroundLight
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Selected state gradient
    static let selectedGlowGradient = LinearGradient(
        colors: [
            AppPalette.color("#1B2A44"),
            AppPalette.color("#152235")
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
    static let small = Shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    static let medium = Shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
    static let large = Shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
    
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
        self.dashboardCardStyle()
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
    
    func dashboardCardStyle(isSelected: Bool = false) -> some View {
        let cornerRadius = AppCornerRadius.large
        
        return self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppColors.selectedGlowGradient)
                            .opacity(isSelected ? 0.6 : 0)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                isSelected ? AppColors.accent.opacity(0.6) : AppColors.border,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppColors.borderLight.opacity(0.35), lineWidth: 1)
                            .blendMode(.screen)
                    )
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.45 : 0.35),
                radius: isSelected ? 18 : 12,
                x: 0,
                y: 8
            )
    }
    
    func glassCardStyle() -> some View {
        self.dashboardCardStyle()
    }
    
    func glowEffect(intensity: CGFloat = 0.3) -> some View {
        self
            .shadow(color: AppColors.glowBlue.opacity(intensity * 0.2), radius: 8, x: 0, y: 0)
    }
}
