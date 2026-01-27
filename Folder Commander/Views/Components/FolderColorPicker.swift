//
//  FolderColorPicker.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI

struct FolderColorPicker: View {
    @Binding var selectedColorHex: String?
    let defaultColorHex: String?
    @State private var showingCustomColorPicker = false
    @State private var customColor: Color = .blue
    
    // Preset colors palette
    private let presetColors: [(name: String, hex: String)] = [
        ("Blue", "#007AFF"),
        ("Green", "#34C759"),
        ("Orange", "#FF9500"),
        ("Red", "#FF3B30"),
        ("Purple", "#AF52DE"),
        ("Pink", "#FF2D55"),
        ("Yellow", "#FFCC00"),
        ("Teal", "#5AC8FA"),
        ("Indigo", "#5856D6"),
        ("Brown", "#A2845E"),
        ("Gray", "#8E8E93"),
        ("Cyan", "#32D74B"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Folder Color")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            
            // Current color preview
            HStack(spacing: AppSpacing.md) {
                Circle()
                    .fill(displayColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                
                Text(colorLabel)
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
            
            // Preset colors grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    // Default option
                    ColorOptionButton(
                        color: nil,
                        label: "Default",
                        isSelected: selectedColorHex == nil,
                        defaultColorHex: defaultColorHex
                    ) {
                        selectedColorHex = nil
                    }
                    
                    // Preset colors
                    ForEach(presetColors, id: \.hex) { preset in
                        ColorOptionButton(
                            color: Color(hex: preset.hex),
                            label: preset.name,
                            isSelected: selectedColorHex == preset.hex,
                            defaultColorHex: defaultColorHex
                        ) {
                            selectedColorHex = preset.hex
                        }
                    }
                    
                    // Custom color option
                    Button(action: {
                        if let hex = selectedColorHex, let color = Color(hex: hex) {
                            customColor = color
                        }
                        showingCustomColorPicker = true
                    }) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 12))
                            Text("Custom")
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                .fill(AppColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, AppSpacing.xs)
            }
        }
        .sheet(isPresented: $showingCustomColorPicker) {
            CustomColorPickerSheet(
                color: $customColor,
                selectedColorHex: $selectedColorHex
            )
        }
    }
    
    private var displayColor: Color {
        if let hex = selectedColorHex, let color = Color(hex: hex) {
            return color
        }
        if let defaultHex = defaultColorHex, let color = Color(hex: defaultHex) {
            return color
        }
        return AppColors.primary
    }
    
    private var colorLabel: String {
        if let hex = selectedColorHex {
            if let preset = presetColors.first(where: { $0.hex == hex }) {
                return preset.name
            }
            return "Custom"
        }
        return "Default"
    }
}

struct ColorOptionButton: View {
    let color: Color?
    let label: String
    let isSelected: Bool
    let defaultColorHex: String?
    let action: () -> Void
    
    private var displayColor: Color {
        if let color = color {
            return color
        }
        if let defaultHex = defaultColorHex, let defaultColor = Color(hex: defaultHex) {
            return defaultColor
        }
        return AppColors.primary
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(displayColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? AppColors.accent : AppColors.border,
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? AppColors.accent.opacity(0.3) : Color.clear,
                        radius: isSelected ? 4 : 0
                    )
                
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct CustomColorPickerSheet: View {
    @Binding var color: Color
    @Binding var selectedColorHex: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Color preview
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(color)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                            .stroke(AppColors.border, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Native color picker
                ColorPicker("Select Color", selection: $color, supportsOpacity: false)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(AppColors.surfaceElevated)
                    )
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppColors.contentGradient)
            .navigationTitle("Custom Color")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedColorHex = color.toHex()
                        dismiss()
                    }
                    .primaryButton()
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    FolderColorPicker(selectedColorHex: .constant(nil), defaultColorHex: nil)
        .padding()
}
