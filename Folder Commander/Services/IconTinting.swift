//
//  IconTinting.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import AppKit
import UniformTypeIdentifiers
import CoreImage

extension NSImage {
    // Standard macOS icon sizes (includes @2x coverage via larger reps)
    private static let iconRepresentationSizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
    
    /// Tint the image with the specified color while preserving all shading and details
    /// Uses Core Image hue rotation to shift the folder's blue to the target color
    /// Creates a crisp colored folder icon with multiple representations
    func tinted(with color: NSColor) -> NSImage {
        // Use Core Image to properly tint the folder while preserving details
        guard let tintedImage = applyHueShift(to: color) else {
            // Fallback to the rendering method if Core Image fails
            return renderedFolderIcon(tintColor: color, symbolName: nil, symbolColor: .clear, badgePosition: .center)
        }
        return tintedImage
    }
    
    /// Apply hue shift using Core Image to change folder color while preserving all details
    private func applyHueShift(to targetColor: NSColor) -> NSImage? {
        // Convert NSImage to CIImage
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else {
            return nil
        }
        
        // Get the target hue from the color
        var targetHue: CGFloat = 0
        var targetSaturation: CGFloat = 0
        // targetBrightness is available if needed for future brightness adjustments
        var targetBrightness: CGFloat = 0
        _ = targetBrightness // Suppress unused variable warning
        
        // Convert to HSB color space
        if let hsbColor = targetColor.usingColorSpace(.deviceRGB) {
            targetHue = hsbColor.hueComponent
            targetSaturation = hsbColor.saturationComponent
            targetBrightness = hsbColor.brightnessComponent
        } else {
            return nil
        }
        
        // The default macOS folder is blue with hue around 0.6 (216 degrees / 360)
        let folderBlueHue: CGFloat = 0.6
        
        // Calculate the hue shift needed (in radians for CIHueAdjust)
        // CIHueAdjust uses radians: full circle = 2π
        let hueShift = (targetHue - folderBlueHue) * 2 * .pi
        
        // Apply hue adjustment filter
        guard let hueFilter = CIFilter(name: "CIHueAdjust") else {
            return nil
        }
        hueFilter.setValue(ciImage, forKey: kCIInputImageKey)
        hueFilter.setValue(hueShift, forKey: kCIInputAngleKey)
        
        guard var outputImage = hueFilter.outputImage else {
            return nil
        }
        
        // If target saturation is significantly different, apply saturation adjustment
        // The default folder has moderate saturation (~0.7)
        let folderSaturation: CGFloat = 0.7
        let saturationRatio = targetSaturation / folderSaturation
        
        if abs(saturationRatio - 1.0) > 0.1 {
            guard let satFilter = CIFilter(name: "CIColorControls") else {
                return nil
            }
            satFilter.setValue(outputImage, forKey: kCIInputImageKey)
            satFilter.setValue(saturationRatio, forKey: kCIInputSaturationKey)
            satFilter.setValue(0.0, forKey: kCIInputBrightnessKey)
            satFilter.setValue(1.0, forKey: kCIInputContrastKey)
            
            if let satOutput = satFilter.outputImage {
                outputImage = satOutput
            }
        }
        
        // Convert CIImage back to NSImage
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        let resultImage = NSImage(cgImage: cgImage, size: self.size)
        
        // Copy over all representations for proper multi-resolution support
        return createMultiResolutionImage(from: resultImage)
    }
    
    /// Create a multi-resolution image with all standard icon sizes
    private func createMultiResolutionImage(from sourceImage: NSImage) -> NSImage {
        let finalImage = NSImage(size: NSSize(width: 1024, height: 1024))
        
        for size in Self.iconRepresentationSizes {
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
                continue
            }
            
            NSGraphicsContext.saveGraphicsState()
            let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
            NSGraphicsContext.current = context
            context?.imageInterpolation = .high
            context?.shouldAntialias = true
            
            let drawRect = NSRect(origin: .zero, size: NSSize(width: size, height: size))
            sourceImage.draw(
                in: drawRect,
                from: NSRect(origin: .zero, size: sourceImage.size),
                operation: .sourceOver,
                fraction: 1.0
            )
            
            NSGraphicsContext.restoreGraphicsState()
            
            bitmapRep.size = NSSize(width: size, height: size)
            finalImage.addRepresentation(bitmapRep)
        }
        
        return finalImage
    }
    
    /// Get the default folder icon from the system
    /// Safely handles edge cases to prevent crashes
    /// Uses multiple fallback methods to ensure we get the true macOS folder icon
    static func defaultFolderIcon() -> NSImage {
        // Method 1: Try to get folder icon using content type (modern API, macOS 12.0+)
        if #available(macOS 12.0, *) {
            if let folderType = UTType("public.folder") {
                let folderIcon = NSWorkspace.shared.icon(for: folderType)
                if folderIcon.size.width > 0 && folderIcon.size.height > 0 {
                    return folderIcon
                }
            }
        } else {
            // Fallback for older macOS versions
            let folderIcon = NSWorkspace.shared.icon(forFileType: "public.folder")
            if folderIcon.size.width > 0 && folderIcon.size.height > 0 {
                return folderIcon
            }
        }
        
        // Method 2: Fallback to home directory icon
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        if !homeDirectory.isEmpty {
            let icon = NSWorkspace.shared.icon(forFile: homeDirectory)
            if icon.size.width > 0 && icon.size.height > 0 {
                return icon
            }
        }
        
        // Method 3: Last resort - root directory icon
        return NSWorkspace.shared.icon(forFile: "/")
    }
    
    /// Composite an SF Symbol onto the folder icon
    /// Creates a folder icon with an SF Symbol embedded in the center
    func compositedWithSFSymbol(symbolName: String, symbolColor: NSColor = NSColor(white: 0.25, alpha: 0.85), badgePosition: BadgePosition = .center) -> NSImage {
        return renderedFolderIcon(tintColor: nil, symbolName: symbolName, symbolColor: symbolColor, badgePosition: badgePosition)
    }
    
    /// Create a folder icon with optional color tint and SF Symbol
    static func customFolderIcon(color: NSColor? = nil, symbolName: String? = nil, symbolColor: NSColor = NSColor(white: 0.25, alpha: 0.85)) -> NSImage {
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
        
        // Note: Folder tinting is now handled by Core Image in applyHueShift()
        // This method is only used for adding SF Symbol overlays
        
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
        // Icon size reduced to 40% for a more subtle, balanced look
        let iconSize = NSSize(width: size * 0.40, height: size * 0.40)
        switch badgePosition {
        case .bottomRight:
            return NSRect(
                x: size - iconSize.width * 0.7 - size * 0.1,
                y: size * 0.05,
                width: iconSize.width * 0.7,
                height: iconSize.height * 0.7
            )
        case .center:
            // Centered on the folder face with slight downward offset to account for folder tab
            return NSRect(
                x: (size - iconSize.width) / 2,
                y: (size - iconSize.height) / 2 - size * 0.02,
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
