//
//  Template.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation

struct Template: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var rootItem: FolderItem
    var createdDate: Date
    var modifiedDate: Date
    
    init(id: UUID = UUID(), name: String, rootItem: FolderItem, createdDate: Date = Date(), modifiedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.rootItem = rootItem
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
    }
    
    // Create a copy with updated modified date
    func updated() -> Template {
        Template(id: id, name: name, rootItem: rootItem, createdDate: createdDate, modifiedDate: Date())
    }
}
