//
//  FileSystemService.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation

enum FileSystemError: LocalizedError {
    case invalidURL
    case creationFailed(String)
    case permissionDenied
    case fileAlreadyExists(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid file or folder path"
        case .creationFailed(let message):
            return "Failed to create: \(message)"
        case .permissionDenied:
            return "Permission denied. Please grant access to the selected folder."
        case .fileAlreadyExists(let path):
            return "File or folder already exists: \(path)"
        }
    }
}

class FileSystemService {
    private let fileManager = FileManager.default
    
    /// Creates a project structure from a template at the specified location
    /// - Parameters:
    ///   - template: The template to use
    ///   - projectName: Name of the root folder to create
    ///   - parentURL: The parent directory where the project folder will be created
    /// - Returns: The URL of the created project folder
    /// - Throws: FileSystemError if creation fails
    func createProject(from template: Template, name projectName: String, at parentURL: URL) async throws -> URL {
        // Validate parent URL
        guard parentURL.isFileURL else {
            throw FileSystemError.invalidURL
        }
        
        // Check if parent directory exists and is accessible
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: parentURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw FileSystemError.invalidURL
        }
        
        // Create project root folder
        let projectURL = parentURL.appendingPathComponent(projectName, isDirectory: true)
        
        // Check if project folder already exists
        if fileManager.fileExists(atPath: projectURL.path) {
            throw FileSystemError.fileAlreadyExists(projectURL.path)
        }
        
        // Start accessing security-scoped resource if needed
        let accessing = parentURL.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                parentURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            // Create project root directory
            try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: false, attributes: nil)
            
            // Create children of rootItem directly (skip the root folder itself)
            if let children = template.rootItem.children {
                for child in children {
                    try await createItem(child, at: projectURL)
                }
            }
            
            return projectURL
        } catch {
            // Clean up project folder if creation failed
            if fileManager.fileExists(atPath: projectURL.path) {
                try? fileManager.removeItem(at: projectURL)
            }
            throw FileSystemError.creationFailed(error.localizedDescription)
        }
    }
    
    /// Recursively creates folders and files from a FolderItem
    private func createItem(_ item: FolderItem, at parentURL: URL) async throws {
        let itemURL = parentURL.appendingPathComponent(item.name, isDirectory: item.type == .folder)
        
        switch item.type {
        case .folder:
            // Create directory
            try fileManager.createDirectory(at: itemURL, withIntermediateDirectories: false, attributes: nil)
            
            // Create children recursively
            if let children = item.children {
                for child in children {
                    try await createItem(child, at: itemURL)
                }
            }
            
        case .file:
            // Create file with optional content
            let content = item.content ?? ""
            let data = content.data(using: .utf8) ?? Data()
            try data.write(to: itemURL, options: .atomic)
        }
    }
    
    /// Validates that a URL is accessible and writable
    func validateURL(_ url: URL) -> Bool {
        guard url.isFileURL else { return false }
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return false
        }
        
        return fileManager.isWritableFile(atPath: url.path)
    }
}
