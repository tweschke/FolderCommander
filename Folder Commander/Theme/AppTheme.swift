//
//  AppTheme.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

// MARK: - Color Theme
struct AppColors {
    // Primary colors - purple-blue for icons and accents (kept for branding)
    static let primary = Color(red: 0.4, green: 0.25, blue: 0.7)  // Purple-blue for icons
    static let primaryLight = Color(red: 0.55, green: 0.4, blue: 0.85)  // Lighter purple-blue
    static let primaryDark = Color(red: 0.3, green: 0.2, blue: 0.6)  // Darker purple-blue
    
    // Accent colors - light blue for active states
    static let accent = Color(red: 0.2, green: 0.6, blue: 1.0)  // Light blue
    static let accentLight = Color(red: 0.4, green: 0.7, blue: 1.0)  // Very light blue
    static let accentMagenta = Color(red: 0.9, green: 0.3, blue: 0.7)  // Vibrant magenta
    
    // Success/Positive
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let successLight = Color(red: 0.3, green: 0.8, blue: 0.5)
    
    // Warning
    static let warning = Color(red: 1.0, green: 0.65, blue: 0.0)
    
    // Destructive
    static let destructive = Color(red: 0.9, green: 0.25, blue: 0.3)
    static let destructiveLight = Color(red: 0.95, green: 0.35, blue: 0.4)
    
    // Backgrounds - clean light colors
    static let background = Color(red: 0.98, green: 0.98, blue: 0.99)  // Off-white background
    static let backgroundLight = Color.white  // Pure white
    static let secondaryBackground = Color(red: 0.97, green: 0.97, blue: 0.98)  // Light grey for sidebar
    static let tertiaryBackground = Color(red: 0.95, green: 0.95, blue: 0.96)  // Slightly darker for cards
    
    // Surfaces (for cards, panels) - light translucent
    static let surface = Color.white.opacity(0.9)
    static let surfaceElevated = Color.white.opacity(0.95)
    
    // Text - dark for light backgrounds
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.15)  // Dark grey/black
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.45)  // Medium grey
    static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.65)  // Light grey
    static let textInactive = Color(red: 0.7, green: 0.7, blue: 0.75)  // Very light grey
    
    // Borders
    static let border = Color(red: 0.85, green: 0.85, blue: 0.9)  // Light grey border
    static let borderLight = Color(red: 0.9, green: 0.9, blue: 0.95)  // Very light border
    static let borderGlow = Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3)  // Light blue glow
    
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
    
    // Background gradients for sidebar and content areas - light and clean
    static let sidebarGradient = LinearGradient(
        colors: [
            Color(red: 0.97, green: 0.97, blue: 0.98),
            Color(red: 0.98, green: 0.98, blue: 0.99)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let contentGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.98, blue: 0.99),
            Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Selected state gradient - light blue background
    static let selectedGlowGradient = LinearGradient(
        colors: [
            Color(red: 0.9, green: 0.95, blue: 1.0),  // Very light blue
            Color(red: 0.85, green: 0.92, blue: 1.0)  // Slightly darker light blue
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
