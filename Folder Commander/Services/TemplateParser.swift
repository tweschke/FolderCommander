//
//  TemplateParser.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation

enum TemplateParserError: LocalizedError {
    case invalidFormat
    case emptyInput
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid template format. Use indentation to represent folder hierarchy."
        case .emptyInput:
            return "Template cannot be empty."
        }
    }
}

class TemplateParser {
    /// Parses a text input into a FolderItem hierarchy
    /// Format: Each line represents an item. Indentation (spaces or tabs) represents nesting.
    /// Files are detected by having a file extension or starting with a dot (like .gitignore)
    /// - Parameter text: The text input to parse
    /// - Returns: A FolderItem representing the root of the structure
    /// - Throws: TemplateParserError if parsing fails
    static func parse(_ text: String) throws -> FolderItem {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else {
            throw TemplateParserError.emptyInput
        }
        
        // Parse lines into items with indentation levels
        var items: [(level: Int, name: String)] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            
            // Count leading spaces/tabs to determine indentation level
            let leadingWhitespace = line.prefix { $0 == " " || $0 == "\t" }
            let level = leadingWhitespace.count
            
            items.append((level: level, name: trimmed))
        }
        
        guard !items.isEmpty else {
            throw TemplateParserError.emptyInput
        }
        
        // Build hierarchy from indentation levels
        return try buildHierarchy(from: items)
    }
    
    /// Builds a FolderItem hierarchy from parsed items using a recursive approach
    private static func buildHierarchy(from items: [(level: Int, name: String)]) throws -> FolderItem {
        guard let firstItem = items.first else {
            throw TemplateParserError.emptyInput
        }
        
        // Build tree recursively
        var index = 0
        return try buildTree(from: items, startIndex: &index, currentLevel: firstItem.level)
    }
    
    /// Recursively builds the tree structure
    private static func buildTree(from items: [(level: Int, name: String)], startIndex: inout Int, currentLevel: Int) throws -> FolderItem {
        guard startIndex < items.count else {
            throw TemplateParserError.invalidFormat
        }
        
        let currentItem = items[startIndex]
        let itemType = determineType(for: currentItem.name)
        var children: [FolderItem] = []
        
        // Process children (items with higher indentation level)
        startIndex += 1
        while startIndex < items.count {
            let nextItem = items[startIndex]
            
            // If next item is at same or lower level, it's a sibling or parent - stop processing children
            if nextItem.level <= currentLevel {
                break
            }
            
            // If next item is exactly one level deeper, it's a direct child
            if nextItem.level == currentLevel + 1 {
                if itemType == .folder {
                    let child = try buildTree(from: items, startIndex: &startIndex, currentLevel: nextItem.level)
                    children.append(child)
                } else {
                    // Files shouldn't have children, skip deeper items
                    break
                }
            } else {
                // Item is more than one level deeper - this shouldn't happen with proper indentation
                // Skip it or treat as error
                startIndex += 1
            }
        }
        
        // Create the item
        return FolderItem(
            name: currentItem.name,
            type: itemType,
            children: children.isEmpty && itemType == .folder ? [] : (children.isEmpty ? nil : children)
        )
    }
    
    /// Determines if an item is a file or folder based on its name
    private static func determineType(for name: String) -> ItemType {
        // Files typically have extensions or start with a dot
        if name.contains(".") && !name.hasSuffix(".") {
            // Check if it's a file extension (not just a dot in the middle)
            let components = name.split(separator: ".")
            if components.count > 1 {
                let lastComponent = components.last ?? ""
                // If last component looks like an extension (short, alphanumeric)
                if lastComponent.count <= 5 && lastComponent.allSatisfy({ $0.isLetter || $0.isNumber }) {
                    return .file
                }
            }
        }
        
        // Files starting with dot (like .gitignore, .env)
        if name.hasPrefix(".") {
            return .file
        }
        
        // Default to folder
        return .folder
    }
}
