//
//  FolderItem.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation
import SwiftUI

enum ItemType: String, Codable {
    case folder
    case file
}

struct FolderItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var type: ItemType
    var children: [FolderItem]?
    var content: String?
    var color: String? // Hex color string (e.g., "#FF5733")
    var icon: String? // SF Symbol name (e.g., "doc.text.fill", "photo.fill")
    
    init(id: UUID = UUID(), name: String, type: ItemType, children: [FolderItem]? = nil, content: String? = nil, color: String? = nil, icon: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.children = children
        self.content = content
        self.color = color
        self.icon = icon
    }
    
    // Convenience initializers
    static func folder(name: String, children: [FolderItem] = [], color: String? = nil, icon: String? = nil) -> FolderItem {
        FolderItem(name: name, type: .folder, children: children, color: color, icon: icon)
    }
    
    static func file(name: String, content: String? = nil) -> FolderItem {
        FolderItem(name: name, type: .file, content: content)
    }
    
    // MARK: - Color Helpers
    
    /// Convert hex string to SwiftUI Color
    func getColor() -> Color? {
        guard let hex = color else { return nil }
        return Color(hex: hex)
    }
    
    /// Get display color with fallback chain: custom color → default color → app primary
    func getDisplayColor(defaultColor: String? = nil) -> Color {
        if let customColor = getColor() {
            return customColor
        }
        if let defaultHex = defaultColor, let defaultColor = Color(hex: defaultHex) {
            return defaultColor
        }
        return AppColors.primary
    }
    
    // MARK: - Icon Helpers
    
    /// Get SF Symbol icon name
    func getIconName() -> String? {
        return icon
    }
    
    // Helper method to check if item has children
    var hasChildren: Bool {
        guard let children = children else { return false }
        return !children.isEmpty
    }
    
    // Helper method to get all items recursively (for preview/validation)
    func getAllItems() -> [FolderItem] {
        var items = [self]
        if let children = children {
            for child in children {
                items.append(contentsOf: child.getAllItems())
            }
        }
        return items
    }
}
