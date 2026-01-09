//
//  FolderItem.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation

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
    
    init(id: UUID = UUID(), name: String, type: ItemType, children: [FolderItem]? = nil, content: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.children = children
        self.content = content
    }
    
    // Convenience initializers
    static func folder(name: String, children: [FolderItem] = []) -> FolderItem {
        FolderItem(name: name, type: .folder, children: children)
    }
    
    static func file(name: String, content: String? = nil) -> FolderItem {
        FolderItem(name: name, type: .file, content: content)
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
