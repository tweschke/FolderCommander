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
    @State private var showingColorBrowser = false
    @State private var customColor: Color = .blue
    
    // Apple's default folder blue color (approximate)
    private static let appleFolderBlue = Color(red: 0.33, green: 0.67, blue: 0.95)
    
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
                if let hex = selectedColorHex, let color = Color(hex: hex) {
                    // Show selected color
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    
                    Text(colorLabel)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    // Show Apple default folder icon
                    Image(systemName: "folder.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Self.appleFolderBlue)
                        .frame(width: 32, height: 32)
                    
                    Text("Apple Default")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
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
            
            // Clear and Change buttons (mirrors FolderIconPicker pattern)
            HStack(spacing: AppSpacing.md) {
                // Clear button (only show if color is selected)
                if selectedColorHex != nil {
                    Button(action: {
                        selectedColorHex = nil
                    }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Clear Color")
                                .font(AppTypography.body)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryButton()
                }
                
                // Browse/Change button
                Button(action: {
                    if let hex = selectedColorHex, let color = Color(hex: hex) {
                        customColor = color
                    }
                    showingColorBrowser = true
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: selectedColorHex != nil ? "pencil.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 16))
                        Text(selectedColorHex != nil ? "Change Color" : "Select Color")
                            .font(AppTypography.body)
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryButton()
            }
        }
        .sheet(isPresented: $showingColorBrowser) {
            ColorBrowserSheet(
                selectedColorHex: $selectedColorHex,
                customColor: $customColor,
                presetColors: presetColors
            )
        }
    }
    
    private var colorLabel: String {
        if let hex = selectedColorHex {
            if let preset = presetColors.first(where: { $0.hex == hex }) {
                return preset.name
            }
            return "Custom"
        }
        return "Apple Default"
    }
}

struct ColorBrowserSheet: View {
    @Binding var selectedColorHex: String?
    @Binding var customColor: Color
    let presetColors: [(name: String, hex: String)]
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Preset colors grid
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Preset Colors")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 70), spacing: AppSpacing.md)
                    ], spacing: AppSpacing.md) {
                        ForEach(presetColors, id: \.hex) { preset in
                            ColorOptionButton(
                                color: Color(hex: preset.hex) ?? .gray,
                                label: preset.name,
                                isSelected: selectedColorHex == preset.hex
                            ) {
                                selectedColorHex = preset.hex
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
                
                Divider()
                    .background(AppColors.border)
                
                // Custom color section
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Custom Color")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: AppSpacing.md) {
                        // Color preview
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(customColor)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        
                        // Native color picker
                        ColorPicker("Pick a color", selection: $customColor, supportsOpacity: false)
                            .labelsHidden()
                        
                        Spacer()
                        
                        Button("Apply Custom") {
                            selectedColorHex = customColor.toHex()
                        }
                        .secondaryButton()
                    }
                }
                .padding(AppSpacing.lg)
                
                Spacer(minLength: 0)
            }
            .background(AppColors.background)
            .navigationTitle("Select Folder Color")
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
        .frame(width: 500, height: 520)
    }
}

struct ColorOptionButton: View {
    let color: Color
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(color)
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

#Preview {
    FolderColorPicker(selectedColorHex: .constant(nil), defaultColorHex: nil)
        .padding()
}
