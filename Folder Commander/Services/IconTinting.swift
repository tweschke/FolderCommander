//
//  IconTinting.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import AppKit
import UniformTypeIdentifiers

extension NSImage {
    /// Tint the image with the specified color
    /// Creates a high-resolution, crisp colored folder icon using Core Graphics
    /// Safely handles errors to prevent crashes
    func tinted(with color: NSColor) -> NSImage {
        // Use high resolution for crisp icons (256x256 is sufficient and more memory-efficient)
        // macOS will scale it up as needed
        let targetSize = NSSize(width: 256, height: 256)
        
        // Ensure original image is valid
        guard self.size.width > 0 && self.size.height > 0 else {
            return self // Return original if invalid
        }
        
        // Use the simpler lockFocus approach which is more reliable and doesn't crash
        // This avoids the problematic cgImage(forProposedRect:context:hints:) method
        return tintedUsingLockFocus(color: color, targetSize: targetSize)
    }
    
    /// Method using lockFocus for safe icon tinting
    /// This approach is more reliable and doesn't crash like the CGImage method
    private func tintedUsingLockFocus(color: NSColor, targetSize: NSSize) -> NSImage {
        // Ensure we have valid dimensions
        guard targetSize.width > 0 && targetSize.height > 0,
              targetSize.width <= 1024 && targetSize.height <= 1024 else {
            // Return original if dimensions are invalid or too large
            return self
        }
        
        // Validate dimensions are reasonable integers
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        guard width > 0 && height > 0 else {
            return self
        }
        
        // Create a new image for the tinted result
        let tintedImage = NSImage(size: targetSize)
        
        // Safely lock focus and draw
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32
        ) else {
            // Fallback to simpler method if bitmap creation fails
            return tintedUsingSimpleLockFocus(color: color, targetSize: targetSize)
        }
        
        tintedImage.addRepresentation(bitmapRep)
        
        // Safely lock focus with error handling
        tintedImage.lockFocus()
        defer { tintedImage.unlockFocus() }
        
        // Set up graphics context safely
        if let context = NSGraphicsContext.current {
            context.imageInterpolation = .high
            context.shouldAntialias = true
        }
        
        // Draw the original icon scaled to target size
        self.draw(
            in: NSRect(origin: .zero, size: targetSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        // Apply color using sourceAtop blend mode
        color.set()
        NSRect(origin: .zero, size: targetSize).fill(using: .sourceAtop)
        
        return tintedImage
    }
    
    /// Simple fallback method if bitmap creation fails
    private func tintedUsingSimpleLockFocus(color: NSColor, targetSize: NSSize) -> NSImage {
        // Validate dimensions
        guard targetSize.width > 0 && targetSize.height > 0,
              targetSize.width <= 1024 && targetSize.height <= 1024 else {
            return self
        }
        
        let tintedImage = NSImage(size: targetSize)
        tintedImage.lockFocus()
        defer { tintedImage.unlockFocus() }
        
        // Draw the original icon
        self.draw(
            in: NSRect(origin: .zero, size: targetSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        // Apply color tint
        color.set()
        NSRect(origin: .zero, size: targetSize).fill(using: .sourceAtop)
        
        return tintedImage
    }
    
    /// Get the default folder icon from the system
    /// Safely handles edge cases to prevent crashes
    static func defaultFolderIcon() -> NSImage {
        // Try to get folder icon using home directory first
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        
        // Validate path is not empty
        guard !homeDirectory.isEmpty else {
            // Fallback to root directory if home is unavailable
            return NSWorkspace.shared.icon(forFile: "/")
        }
        
        let icon = NSWorkspace.shared.icon(forFile: homeDirectory)
        
        // Ensure we got a valid icon
        guard icon.size.width > 0 && icon.size.height > 0 else {
            // Fallback to root directory icon if home icon is invalid
            return NSWorkspace.shared.icon(forFile: "/")
        }
        
        return icon
    }
    
    /// Composite an SF Symbol onto the folder icon
    /// Creates a folder icon with an SF Symbol embedded in the center
    /// - Parameters:
    ///   - symbolName: The SF Symbol name (e.g., "doc.text.fill")
    ///   - symbolColor: Color for the symbol (defaults to very dark grey)
    ///   - badgePosition: Position of the symbol (defaults to center for embedded look)
    /// - Returns: A new NSImage with the symbol composited, or original if symbol is invalid
    func compositedWithSFSymbol(symbolName: String, symbolColor: NSColor = NSColor(white: 0.15, alpha: 1.0), badgePosition: BadgePosition = .center) -> NSImage {
        let targetSize = self.size
        // Use a consistent icon size (55% of folder) to calculate symbol point size
        let symbolArea = NSSize(width: targetSize.width * 0.55, height: targetSize.height * 0.55)
        // Build configuration for symbol to match icon size for crisp rendering
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: max(symbolArea.width, symbolArea.height), weight: .medium)
        guard let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
                .withSymbolConfiguration(symbolConfig) else {
            return self
        }
        
        // Ensure symbol image is valid
        guard symbolImage.size.width > 0 && symbolImage.size.height > 0 else {
            return self
        }
        
        let compositedImage = NSImage(size: targetSize)
        
        // Create bitmap representation
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(targetSize.width),
            pixelsHigh: Int(targetSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: Int(targetSize.width) * 4,
            bitsPerPixel: 32
        ) else {
            return compositedWithSFSymbolSimple(symbolName: symbolName, symbolColor: symbolColor, badgePosition: badgePosition)
        }
        
        compositedImage.addRepresentation(bitmapRep)
        
        compositedImage.lockFocus()
        defer { compositedImage.unlockFocus() }
        
        // Set up graphics context
        if let context = NSGraphicsContext.current {
            context.imageInterpolation = .high
            context.shouldAntialias = true
        }
        
        // Draw the base folder icon
        self.draw(
            in: NSRect(origin: .zero, size: targetSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        // Calculate icon size and position - make it larger and centered for embedded look
        // Use 55% of folder size for a prominent, integrated appearance
        let iconSize = NSSize(width: targetSize.width * 0.55, height: targetSize.height * 0.55)
        let iconRect: NSRect
        
        switch badgePosition {
        case .bottomRight:
            // Legacy badge position (smaller, bottom-right)
            iconRect = NSRect(
                x: targetSize.width - iconSize.width * 0.7 - targetSize.width * 0.1,
                y: targetSize.height * 0.05,
                width: iconSize.width * 0.7,
                height: iconSize.height * 0.7
            )
        case .center:
            // Center the icon prominently on the folder face
            // Slightly offset downward for better visual centering
            iconRect = NSRect(
                x: (targetSize.width - iconSize.width) / 2,
                y: (targetSize.height - iconSize.height) / 2 - targetSize.height * 0.02,
                width: iconSize.width,
                height: iconSize.height
            )
        }
        
        // Create a tinted copy of the symbol image
        let tintedSymbol = NSImage(size: symbolImage.size)
        tintedSymbol.lockFocus()

        // Draw original symbol
        symbolImage.draw(
            in: NSRect(origin: .zero, size: symbolImage.size),
            from: NSRect(origin: .zero, size: symbolImage.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        // Apply color tint
        symbolColor.set()
        NSRect(origin: .zero, size: symbolImage.size).fill(using: .sourceAtop)

        tintedSymbol.unlockFocus()

        // Draw the tinted symbol embedded into the folder icon
        tintedSymbol.draw(
            in: iconRect,
            from: NSRect(origin: .zero, size: symbolImage.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        return compositedImage
    }
    
    /// Simple fallback method for symbol compositing
    private func compositedWithSFSymbolSimple(symbolName: String, symbolColor: NSColor, badgePosition: BadgePosition) -> NSImage {
        let targetSize = self.size
        let symbolArea = NSSize(width: targetSize.width * 0.55, height: targetSize.height * 0.55)
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: max(symbolArea.width, symbolArea.height), weight: .medium)
        guard let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
                .withSymbolConfiguration(symbolConfig),
              symbolImage.size.width > 0 && symbolImage.size.height > 0 else {
            return self
        }
        
      
        let compositedImage = NSImage(size: targetSize)
        
        compositedImage.lockFocus()
        defer { compositedImage.unlockFocus() }
        
        // Draw base folder icon
        self.draw(
            in: NSRect(origin: .zero, size: targetSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        // Calculate icon position - make it larger and centered for embedded look
        let iconSize = NSSize(width: targetSize.width * 0.55, height: targetSize.height * 0.55)
        let iconRect: NSRect
        
        switch badgePosition {
        case .bottomRight:
            iconRect = NSRect(
                x: targetSize.width - iconSize.width * 0.7 - targetSize.width * 0.1,
                y: targetSize.height * 0.05,
                width: iconSize.width * 0.7,
                height: iconSize.height * 0.7
            )
        case .center:
            // Center the icon prominently on the folder face
            // Slightly offset downward for better visual centering
            iconRect = NSRect(
                x: (targetSize.width - iconSize.width) / 2,
                y: (targetSize.height - iconSize.height) / 2 - targetSize.height * 0.02,
                width: iconSize.width,
                height: iconSize.height
            )
        }
        
        // Create a tinted copy of the symbol image
        let tintedSymbol = NSImage(size: symbolImage.size)
        tintedSymbol.lockFocus()

        // Draw original symbol
        symbolImage.draw(
            in: NSRect(origin: .zero, size: symbolImage.size),
            from: NSRect(origin: .zero, size: symbolImage.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        // Apply color tint
        symbolColor.set()
        NSRect(origin: .zero, size: symbolImage.size).fill(using: .sourceAtop)

        tintedSymbol.unlockFocus()

        // Draw the tinted symbol embedded into the folder icon
        tintedSymbol.draw(
            in: iconRect,
            from: NSRect(origin: .zero, size: symbolImage.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        return compositedImage
    }
    
    /// Create a folder icon with optional color tint and SF Symbol embedded in center
    /// - Parameters:
    ///   - color: Optional color to tint the folder icon
    ///   - symbolName: Optional SF Symbol name to embed in the folder
    ///   - symbolColor: Color for the symbol (defaults to very dark grey for contrast)
    /// - Returns: A new NSImage with the customizations applied
    static func customFolderIcon(color: NSColor? = nil, symbolName: String? = nil, symbolColor: NSColor = NSColor(white: 0.15, alpha: 1.0)) -> NSImage {
        var folderIcon = defaultFolderIcon()
        
        // Apply color tint if provided
        if let color = color {
            folderIcon = folderIcon.tinted(with: color)
        }
        
        // Composite symbol if provided
        if let symbolName = symbolName {
            folderIcon = folderIcon.compositedWithSFSymbol(symbolName: symbolName, symbolColor: symbolColor)
        }
        
        return folderIcon
    }
}

/// Badge position for SF Symbol overlay
enum BadgePosition {
    case bottomRight
    case center
}
