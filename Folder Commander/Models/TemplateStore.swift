//
//  TemplateStore.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation
import Combine
import SwiftUI

class TemplateStore: ObservableObject {
    @Published var templates: [Template] = []
    
    private let userDefaultsKey = "FolderCommanderTemplates"
    
    init() {
        loadTemplates()
    }
    
    // MARK: - Persistence
    
    func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            templates = decoded
        }
    }
    
    func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Template Management
    
    func addTemplate(_ template: Template) {
        templates.append(template)
        saveTemplates()
    }
    
    func updateTemplate(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template.updated()
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func deleteTemplate(at indexSet: IndexSet) {
        templates.remove(atOffsets: indexSet)
        saveTemplates()
    }
    
    // MARK: - Export/Import
    
    func exportTemplate(_ template: Template) -> Data? {
        return try? JSONEncoder().encode(template)
    }
    
    func exportAllTemplates() -> Data? {
        return try? JSONEncoder().encode(templates)
    }
    
    func importTemplate(from data: Data) -> Template? {
        return try? JSONDecoder().decode(Template.self, from: data)
    }
    
    func importTemplates(from data: Data) -> [Template]? {
        return try? JSONDecoder().decode([Template].self, from: data)
    }
    
    func importAndAddTemplate(from data: Data) -> Bool {
        if let template = importTemplate(from: data) {
            // Check if template with same ID already exists
            if templates.contains(where: { $0.id == template.id }) {
                // Generate new ID for imported template
                var newTemplate = template
                newTemplate = Template(id: UUID(), name: template.name, rootItem: template.rootItem, createdDate: template.createdDate, modifiedDate: template.modifiedDate)
                addTemplate(newTemplate)
            } else {
                addTemplate(template)
            }
            return true
        }
        return false
    }
    
    func importAndAddTemplates(from data: Data) -> Int {
        // Try to decode as array first (for bulk imports)
        if let importedTemplates = importTemplates(from: data) {
            var addedCount = 0
            for template in importedTemplates {
                if !templates.contains(where: { $0.id == template.id }) {
                    addTemplate(template)
                    addedCount += 1
                } else {
                    // Generate new ID for duplicate
                    var newTemplate = template
                    newTemplate = Template(id: UUID(), name: template.name, rootItem: template.rootItem, createdDate: template.createdDate, modifiedDate: template.modifiedDate)
                    addTemplate(newTemplate)
                    addedCount += 1
                }
            }
            return addedCount
        }
        
        // If array decode failed, try single template (for single template exports)
        if let singleTemplate = importTemplate(from: data) {
            if !templates.contains(where: { $0.id == singleTemplate.id }) {
                addTemplate(singleTemplate)
                return 1
            } else {
                // Generate new ID for duplicate
                var newTemplate = singleTemplate
                newTemplate = Template(id: UUID(), name: singleTemplate.name, rootItem: singleTemplate.rootItem, createdDate: singleTemplate.createdDate, modifiedDate: singleTemplate.modifiedDate)
                addTemplate(newTemplate)
                return 1
            }
        }
        
        return 0
    }
}
