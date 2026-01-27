//
//  AppSettings.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import Foundation
import Combine
import SwiftUI
import AppKit

enum ThemePreference: String, CaseIterable, Codable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

class AppSettings: ObservableObject {
    @Published var customColorsEnabled: Bool = false
    @Published var defaultFolderColor: String? = nil
    @Published var themePreference: ThemePreference = .system
    
    private let userDefaultsKey = "FolderCommanderSettings"
    
    init() {
        loadSettings()
        applyAppearance(themePreference)
    }
    
    var preferredColorScheme: ColorScheme? {
        switch themePreference {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    // MARK: - Persistence
    
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(SettingsData.self, from: data) {
            customColorsEnabled = decoded.customColorsEnabled
            defaultFolderColor = decoded.defaultFolderColor
            themePreference = decoded.themePreference
        }
    }
    
    func saveSettings() {
        let data = SettingsData(
            customColorsEnabled: customColorsEnabled,
            defaultFolderColor: defaultFolderColor,
            themePreference: themePreference
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Settings Management
    
    func setCustomColorsEnabled(_ enabled: Bool) {
        customColorsEnabled = enabled
        saveSettings()
    }
    
    func setDefaultFolderColor(_ color: String?) {
        defaultFolderColor = color
        saveSettings()
    }

    func setThemePreference(_ preference: ThemePreference) {
        themePreference = preference
        applyAppearance(preference)
        saveSettings()
    }

    private func applyAppearance(_ preference: ThemePreference) {
        let updateAppearance = {
            let appearance: NSAppearance?
            switch preference {
            case .light:
                appearance = NSAppearance(named: .aqua)
            case .dark:
                appearance = NSAppearance(named: .darkAqua)
            case .system:
                appearance = nil
            }

            NSApp.appearance = appearance
            for window in NSApp.windows {
                window.appearance = appearance
            }
        }

        if Thread.isMainThread {
            updateAppearance()
        } else {
            DispatchQueue.main.async(execute: updateAppearance)
        }
    }
}

// MARK: - Settings Data Model

private struct SettingsData: Codable {
    var customColorsEnabled: Bool
    var defaultFolderColor: String?
    var themePreference: ThemePreference
    
    init(customColorsEnabled: Bool, defaultFolderColor: String?, themePreference: ThemePreference) {
        self.customColorsEnabled = customColorsEnabled
        self.defaultFolderColor = defaultFolderColor
        self.themePreference = themePreference
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        customColorsEnabled = try container.decodeIfPresent(Bool.self, forKey: .customColorsEnabled) ?? false
        defaultFolderColor = try container.decodeIfPresent(String.self, forKey: .defaultFolderColor)
        themePreference = try container.decodeIfPresent(ThemePreference.self, forKey: .themePreference) ?? .system
    }
    
    private enum CodingKeys: String, CodingKey {
        case customColorsEnabled
        case defaultFolderColor
        case themePreference
    }
}
