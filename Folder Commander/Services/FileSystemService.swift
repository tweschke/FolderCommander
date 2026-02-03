//
//  FileSystemService.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import Foundation
import AppKit

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
    private let workspace = NSWorkspace.shared
    
    private struct TokenContext {
        let projectName: String
        let parentName: String
        let currentName: String
        let relativePath: String
        let creationDate: String
    }
    
    private static let creationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    private func creationDateString(from date: Date = Date()) -> String {
        Self.creationDateFormatter.string(from: date)
    }
    
    private func resolveTokens(in text: String, context: TokenContext) -> String {
        guard !text.isEmpty else { return text }
        
        let replacements: [String: String] = [
            "{{projectName}}": context.projectName,
            "{{parentName}}": context.parentName,
            "{{currentName}}": context.currentName,
            "{{relativePath}}": context.relativePath,
            "{{creationDate}}": context.creationDate
        ]
        
        var resolved = text
        for (token, value) in replacements {
            resolved = resolved.replacingOccurrences(of: token, with: value)
        }
        
        return resolved
    }
    
    /// Creates a project structure from a template at the specified location
    /// - Parameters:
    ///   - template: The template to use
    ///   - projectName: Name of the root folder to create
    ///   - parentURL: The parent directory where the project folder will be created
    ///   - appSettings: App settings to check if colors are enabled and get default color
    /// - Returns: The URL of the created project folder
    /// - Throws: FileSystemError if creation fails
    func createProject(from template: Template, name projectName: String, at parentURL: URL, appSettings: AppSettings? = nil) async throws -> URL {
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
        let creationDate = creationDateString()
        defer {
            if accessing {
                parentURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            // Create project root directory
            try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: false, attributes: nil)
            
            // Apply folder color/icon to root folder ONLY if template explicitly specifies them
            let rootItem = template.rootItem
            let hasRootIcon = rootItem.icon != nil
            let hasRootColor = rootItem.color != nil
            
            if hasRootIcon || hasRootColor {
                autoreleasepool {
                    applyFolderIcon(to: projectURL, colorHex: rootItem.color, iconName: rootItem.icon, appSettings: appSettings)
                }
            }
            
            // Create children of rootItem directly (skip the root folder itself)
            if let children = template.rootItem.children {
                for child in children {
                    try await createItem(
                        child,
                        at: projectURL,
                        projectName: projectName,
                        parentRelativePath: "",
                        creationDate: creationDate,
                        appSettings: appSettings
                    )
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
    private func createItem(
        _ item: FolderItem,
        at parentURL: URL,
        projectName: String,
        parentRelativePath: String,
        creationDate: String,
        appSettings: AppSettings? = nil
    ) async throws {
        let parentName = parentURL.lastPathComponent
        let nameContext = TokenContext(
            projectName: projectName,
            parentName: parentName,
            currentName: item.name,
            relativePath: parentRelativePath,
            creationDate: creationDate
        )
        let resolvedName = resolveTokens(in: item.name, context: nameContext)
        let itemURL = parentURL.appendingPathComponent(resolvedName, isDirectory: item.type == .folder)
        
        if fileManager.fileExists(atPath: itemURL.path) {
            throw FileSystemError.fileAlreadyExists(itemURL.path)
        }
        
        let contentContext = TokenContext(
            projectName: projectName,
            parentName: parentName,
            currentName: resolvedName,
            relativePath: parentRelativePath,
            creationDate: creationDate
        )
        let currentRelativePath = parentRelativePath.isEmpty
            ? resolvedName
            : "\(parentRelativePath)/\(resolvedName)"
        
        switch item.type {
        case .folder:
            // Create directory
            try fileManager.createDirectory(at: itemURL, withIntermediateDirectories: false, attributes: nil)
            
            // Apply folder color/icon if template explicitly specifies them
            // Colors and icons are applied independently - both are optional
            let hasCustomIcon = item.icon != nil
            let hasExplicitColor = item.color != nil
            
            // Apply icon and/or color if needed
            if hasCustomIcon || hasExplicitColor {
                autoreleasepool {
                    applyFolderIcon(to: itemURL, colorHex: item.color, iconName: item.icon, appSettings: appSettings)
                }
            }
            
            // Create children recursively
            if let children = item.children {
                for child in children {
                    try await createItem(
                        child,
                        at: itemURL,
                        projectName: projectName,
                        parentRelativePath: currentRelativePath,
                        creationDate: creationDate,
                        appSettings: appSettings
                    )
                }
            }
            
        case .file:
            // Create file with optional content
            let content = resolveTokens(in: item.content ?? "", context: contentContext)
            let data = content.data(using: .utf8) ?? Data()
            try data.write(to: itemURL, options: .atomic)
        }
    }
    
    /// Apply folder icon with optional color tint and SF Symbol badge
    /// This method safely handles icon operations and catches any errors to prevent crashes
    /// - Parameters:
    ///   - url: The folder URL to apply the icon to
    ///   - colorHex: Optional hex color string for tinting
    ///   - iconName: Optional SF Symbol name for badge overlay
    ///   - appSettings: App settings to check if colors are enabled
    private func applyFolderIcon(to url: URL, colorHex: String?, iconName: String?, appSettings: AppSettings?) {
        // Validate URL first
        guard url.isFileURL, !url.path.isEmpty else {
            // Invalid URL, skip icon setting
            return
        }
        
        // Verify the folder exists before trying to set icon
        guard fileManager.fileExists(atPath: url.path) else {
            // Folder doesn't exist yet, skip icon setting
            return
        }
        
        // If no color and no icon, nothing to do
        guard colorHex != nil || iconName != nil else {
            return
        }
        
        // Parse hex color to NSColor if provided
        var nsColor: NSColor? = nil
        if let hexColor = colorHex {
            guard let parsedColor = parseHexToNSColor(hexColor) else {
                // Fallback to Finder label if color parsing fails and no icon
                if iconName == nil {
                    applyFinderLabel(to: url, hexColor: hexColor)
                }
                return
            }
            nsColor = parsedColor
        }
        
        // Wrap entire icon operation in autoreleasepool and add safety checks
        autoreleasepool {
            // Get default folder icon
            let defaultIcon = NSImage.defaultFolderIcon()
            
            // Ensure we have a valid icon
            guard defaultIcon.size.width > 0 && defaultIcon.size.height > 0 else {
                // Fallback to Finder label if icon is invalid and we have a color
                if let hexColor = colorHex {
                    applyFinderLabel(to: url, hexColor: hexColor)
                }
                return
            }
            
            // Create custom icon with color tint and/or symbol badge
            let customIcon: NSImage
            
            if let symbolName = iconName {
                // Use the new compositing method that handles both color and symbol
                // Always use very dark grey for the symbol to ensure visibility against any folder color
                // This matches the mockup where icons are always dark grey for contrast
                let symbolColor = NSColor(white: 0.15, alpha: 1.0) // Very dark grey (RGB ~38,38,38)
                customIcon = NSImage.customFolderIcon(
                    color: nsColor,
                    symbolName: symbolName,
                    symbolColor: symbolColor
                )
            } else if let color = nsColor {
                // Just apply color tint
                customIcon = defaultIcon.tinted(with: color)
            } else {
                // Shouldn't happen, but fallback to default
                customIcon = defaultIcon
            }
            
            // Ensure custom icon is valid
            guard customIcon.size.width > 0 && customIcon.size.height > 0 else {
                // Fallback to Finder label if compositing failed and we have a color
                if let hexColor = colorHex {
                    applyFinderLabel(to: url, hexColor: hexColor)
                }
                // If we only had an icon (no color), try to apply just the color-tinted folder as fallback
                if iconName != nil && colorHex == nil {
                    // Try to apply default folder icon as last resort
                    let _ = workspace.setIcon(defaultIcon, forFile: url.path, options: [])
                }
                return
            }
            
            // Set the custom icon using NSWorkspace
            // Note: This requires write permissions, which should be granted via security-scoped resources
            // This call is safe and won't crash - it returns false on failure
            let success = workspace.setIcon(customIcon, forFile: url.path, options: [])
            
            if !success {
                // If setting icon fails, fall back to Finder label as backup (only if we have a color)
                if let hexColor = colorHex {
                    applyFinderLabel(to: url, hexColor: hexColor)
                }
                // Log failure for debugging (in production, this would be silent)
                print("Failed to set custom icon for folder: \(url.path)")
            }
        }
    }
    
    /// Apply folder icon color by generating a tinted folder icon and setting it
    /// This method safely handles icon operations and catches any errors to prevent crashes
    /// @deprecated: Use applyFolderIcon instead
    private func applyFolderIconColor(to url: URL, hexColor: String) {
        // Validate URL first
        guard url.isFileURL, !url.path.isEmpty else {
            // Invalid URL, skip icon setting
            return
        }
        
        // Verify the folder exists before trying to set icon
        guard fileManager.fileExists(atPath: url.path) else {
            // Folder doesn't exist yet, skip icon setting
            return
        }
        
        // Parse hex color to NSColor
        guard let nsColor = parseHexToNSColor(hexColor) else {
            // Fallback to Finder label if color parsing fails
            applyFinderLabel(to: url, hexColor: hexColor)
            return
        }
        
        // Wrap entire icon operation in autoreleasepool and add safety checks
        autoreleasepool {
            // Get default folder icon
            let defaultIcon = NSImage.defaultFolderIcon()
            
            // Ensure we have a valid icon
            guard defaultIcon.size.width > 0 && defaultIcon.size.height > 0 else {
                // Fallback to Finder label if icon is invalid
                applyFinderLabel(to: url, hexColor: hexColor)
                return
            }
            
            // Tint the icon with the desired color
            // Wrap in autoreleasepool to manage memory
            let tintedIcon = autoreleasepool {
                defaultIcon.tinted(with: nsColor)
            }
            
            // Ensure tinted icon is valid
            guard tintedIcon.size.width > 0 && tintedIcon.size.height > 0 else {
                // Fallback to Finder label if tinting failed
                applyFinderLabel(to: url, hexColor: hexColor)
                return
            }
            
            // Set the custom icon using NSWorkspace
            // Note: This requires write permissions, which should be granted via security-scoped resources
            // This call is safe and won't crash - it returns false on failure
            let success = workspace.setIcon(tintedIcon, forFile: url.path, options: [])
            
            if !success {
                // If setting icon fails, fall back to Finder label as backup
                applyFinderLabel(to: url, hexColor: hexColor)
            }
        }
    }
    
    /// Parse hex string to NSColor
    private func parseHexToNSColor(_ hex: String) -> NSColor? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        return NSColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    /// Apply Finder label as fallback (shows colored dot)
    private func applyFinderLabel(to url: URL, hexColor: String) {
        guard let finderLabel = finderLabelForHexColor(hexColor) else { return }
        
        let nsURL = url as NSURL
        do {
            try nsURL.setResourceValue(finderLabel, forKey: .labelNumberKey)
        } catch {
            // Silently fail if we can't set the label
            print("Failed to set Finder label: \(error.localizedDescription)")
        }
    }
    
    /// Maps hex color to macOS Finder label number (1-7) for fallback
    /// macOS Finder labels: 1=Gray, 2=Green, 3=Purple, 4=Blue, 5=Yellow, 6=Red, 7=Orange
    private func finderLabelForHexColor(_ hex: String) -> Int? {
        guard let nsColor = parseHexToNSColor(hex) else { return nil }
        
        let r = Double(nsColor.redComponent)
        let g = Double(nsColor.greenComponent)
        let b = Double(nsColor.blueComponent)
        
        // Calculate color distance to each Finder label color
        let labelColors: [(r: Double, g: Double, b: Double, label: Int)] = [
            (0.5, 0.5, 0.5, 1),  // Gray
            (0.2, 0.7, 0.3, 2),  // Green
            (0.6, 0.3, 0.7, 3),  // Purple
            (0.2, 0.5, 1.0, 4),  // Blue
            (1.0, 0.9, 0.2, 5),  // Yellow
            (1.0, 0.3, 0.3, 6),  // Red
            (1.0, 0.6, 0.2, 7),  // Orange
        ]
        
        var minDistance = Double.infinity
        var closestLabel: Int?
        
        for labelColor in labelColors {
            let distance = sqrt(
                pow(r - labelColor.r, 2) +
                pow(g - labelColor.g, 2) +
                pow(b - labelColor.b, 2)
            )
            if distance < minDistance {
                minDistance = distance
                closestLabel = labelColor.label
            }
        }
        
        return closestLabel
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
