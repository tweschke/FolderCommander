//
//  IconTinting.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import AppKit
import UniformTypeIdentifiers

extension NSImage {
    // Standard macOS icon sizes (includes @2x coverage via larger reps)
    private static let iconRepresentationSizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
    
    /// Tint the image with the specified color
    /// Creates a crisp colored folder icon with multiple representations
    func tinted(with color: NSColor) -> NSImage {
        return renderedFolderIcon(tintColor: color, symbolName: nil, symbolColor: .clear, badgePosition: .center)
    }
    
    /// Get the default folder icon from the system
    /// Safely handles edge cases to prevent crashes
    static func defaultFolderIcon() -> NSImage {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        
        guard !homeDirectory.isEmpty else {
            return NSWorkspace.shared.icon(forFile: "/")
        }
        
        let icon = NSWorkspace.shared.icon(forFile: homeDirectory)
        
        guard icon.size.width > 0 && icon.size.height > 0 else {
            return NSWorkspace.shared.icon(forFile: "/")
        }
        
        return icon
    }
    
    /// Composite an SF Symbol onto the folder icon
    /// Creates a folder icon with an SF Symbol embedded in the center
    func compositedWithSFSymbol(symbolName: String, symbolColor: NSColor = NSColor(white: 0.15, alpha: 1.0), badgePosition: BadgePosition = .center) -> NSImage {
        return renderedFolderIcon(tintColor: nil, symbolName: symbolName, symbolColor: symbolColor, badgePosition: badgePosition)
    }
    
    /// Create a folder icon with optional color tint and SF Symbol
    static func customFolderIcon(color: NSColor? = nil, symbolName: String? = nil, symbolColor: NSColor = NSColor(white: 0.15, alpha: 1.0)) -> NSImage {
        var folderIcon = defaultFolderIcon()
        
        if let color = color {
            folderIcon = folderIcon.tinted(with: color)
        }
        
        if let symbolName = symbolName {
            folderIcon = folderIcon.compositedWithSFSymbol(symbolName: symbolName, symbolColor: symbolColor)
        }
        
        return folderIcon
    }
    
    // MARK: - Rendering Helpers
    
    private func renderedFolderIcon(tintColor: NSColor?, symbolName: String?, symbolColor: NSColor, badgePosition: BadgePosition) -> NSImage {
        let baseSize = NSSize(width: 1024, height: 1024)
        let image = NSImage(size: baseSize)
        
        for size in Self.iconRepresentationSizes {
            if let rep = renderIconRepresentation(
                size: size,
                tintColor: tintColor,
                symbolName: symbolName,
                symbolColor: symbolColor,
                badgePosition: badgePosition
            ) {
                rep.size = NSSize(width: size, height: size)
                image.addRepresentation(rep)
            }
        }
        
        return image
    }
    
    private func renderIconRepresentation(
        size: CGFloat,
        tintColor: NSColor?,
        symbolName: String?,
        symbolColor: NSColor,
        badgePosition: BadgePosition
    ) -> NSBitmapImageRep? {
        guard size > 0 else { return nil }
        
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size),
            pixelsHigh: Int(size),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }
        
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.current = context
        
        context?.imageInterpolation = .high
        context?.shouldAntialias = true
        
        let drawRect = NSRect(origin: .zero, size: NSSize(width: size, height: size))
        
        // Draw base icon using best available representation
        if let bestRep = self.bestRepresentation(for: drawRect, context: context, hints: nil) {
            bestRep.draw(in: drawRect)
        } else {
            self.draw(
                in: drawRect,
                from: NSRect(origin: .zero, size: self.size),
                operation: .sourceOver,
                fraction: 1.0
            )
        }
        
        // Apply folder tint (if any)
        if let tintColor = tintColor {
            tintColor.set()
            drawRect.fill(using: .sourceAtop)
        }
        
        // Draw symbol overlay (if any)
        if let symbolName = symbolName {
            let iconRect = iconRect(for: size, badgePosition: badgePosition)
            if let symbolImage = symbolImage(for: symbolName, iconRect: iconRect, color: symbolColor) {
                symbolImage.draw(
                    in: iconRect,
                    from: NSRect(origin: .zero, size: symbolImage.size),
                    operation: .sourceOver,
                    fraction: 1.0
                )
            }
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        return bitmapRep
    }
    
    private func iconRect(for size: CGFloat, badgePosition: BadgePosition) -> NSRect {
        let iconSize = NSSize(width: size * 0.55, height: size * 0.55)
        switch badgePosition {
        case .bottomRight:
            return NSRect(
                x: size - iconSize.width * 0.7 - size * 0.1,
                y: size * 0.05,
                width: iconSize.width * 0.7,
                height: iconSize.height * 0.7
            )
        case .center:
            return NSRect(
                x: (size - iconSize.width) / 2,
                y: (size - iconSize.height) / 2 - size * 0.04,
                width: iconSize.width,
                height: iconSize.height
            )
        }
    }
    
    private func symbolImage(for symbolName: String, iconRect: NSRect, color: NSColor) -> NSImage? {
        let symbolPointSize = max(iconRect.width, iconRect.height)
        let sizeConfig = NSImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .medium)
        let colorConfig = NSImage.SymbolConfiguration(paletteColors: [color])
        let symbolConfig = sizeConfig.applying(colorConfig)
        
        guard let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
                .withSymbolConfiguration(symbolConfig),
              symbolImage.size.width > 0,
              symbolImage.size.height > 0 else {
            return nil
        }
        
        return symbolImage
    }
}

/// Badge position for SF Symbol overlay
enum BadgePosition {
    case bottomRight
    case center
}
