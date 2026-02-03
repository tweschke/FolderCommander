//
//  AppSettings.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var customColorsEnabled: Bool = false
    @Published var defaultFolderColor: String? = nil
    
    private let userDefaultsKey = "FolderCommanderSettings"
    
    init() {
        loadSettings()
    }
    
    // MARK: - Persistence
    
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(SettingsData.self, from: data) {
            customColorsEnabled = decoded.customColorsEnabled
            defaultFolderColor = decoded.defaultFolderColor
        }
    }
    
    func saveSettings() {
        let data = SettingsData(
            customColorsEnabled: customColorsEnabled,
            defaultFolderColor: defaultFolderColor
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
}

// MARK: - Settings Data Model

private struct SettingsData: Codable {
    var customColorsEnabled: Bool
    var defaultFolderColor: String?
    
    init(customColorsEnabled: Bool, defaultFolderColor: String?) {
        self.customColorsEnabled = customColorsEnabled
        self.defaultFolderColor = defaultFolderColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        customColorsEnabled = try container.decodeIfPresent(Bool.self, forKey: .customColorsEnabled) ?? false
        defaultFolderColor = try container.decodeIfPresent(String.self, forKey: .defaultFolderColor)
    }
    
    private enum CodingKeys: String, CodingKey {
        case customColorsEnabled
        case defaultFolderColor
    }
}
