//
//  ResizableDivider.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 27/01/2026.
//

import SwiftUI
import AppKit

struct ResizableDivider: View {
    @Binding var width: CGFloat
    let minWidth: CGFloat
    let maxWidth: CGFloat?
    let onDrag: ((CGFloat) -> Void)?
    
    @State private var isDragging = false
    @State private var dragStartWidth: CGFloat = 0
    @State private var dragStartLocation: CGFloat = 0
    @State private var localWidth: CGFloat = 0
    @State private var lastUpdateTime: CFTimeInterval = 0
    
    init(
        width: Binding<CGFloat>,
        minWidth: CGFloat = 150,
        maxWidth: CGFloat? = nil,
        onDrag: ((CGFloat) -> Void)? = nil
    ) {
        self._width = width
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.onDrag = onDrag
    }
    
    var body: some View {
        ZStack {
            // Visible divider line - optimized for performance
            Rectangle()
                .fill(isDragging ? AppColors.accent : AppColors.border)
                .frame(width: isDragging ? 2 : 1)
            
            // Invisible drag area (wider for easier grabbing)
            Rectangle()
                .fill(Color.clear)
                .frame(width: 8)
                .contentShape(Rectangle())
        }
        .onHover { hovering in
            if hovering && !isDragging {
                NSCursor.resizeLeftRight.push()
            } else if !hovering && !isDragging {
                NSCursor.pop()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let currentTime = CACurrentMediaTime()
                    
                    if !isDragging {
                        isDragging = true
                        dragStartWidth = width
                        dragStartLocation = value.location.x
                        localWidth = width
                        lastUpdateTime = currentTime
                        NSCursor.resizeLeftRight.push()
                    }
                    
                    let delta = value.location.x - dragStartLocation
                    var newWidth = dragStartWidth + delta
                    
                    // Apply constraints
                    newWidth = max(newWidth, minWidth)
                    if let maxWidth = maxWidth {
                        newWidth = min(newWidth, maxWidth)
                    }
                    
                    // Update local state immediately for visual feedback
                    localWidth = newWidth
                    
                    // Throttle binding updates to reduce CPU usage (update max 20 times per second)
                    // This significantly reduces view hierarchy recalculations
                    let timeSinceLastUpdate = currentTime - lastUpdateTime
                    if timeSinceLastUpdate >= 0.05 || abs(width - newWidth) > 10.0 {
                        lastUpdateTime = currentTime
                        
                        // Update binding without animation to prevent layout recalculations
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            width = newWidth
                        }
                    }
                }
                .onEnded { _ in
                    // Ensure final value is committed
                    if abs(width - localWidth) > 0.1 {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            width = localWidth
                        }
                    }
                    
                    isDragging = false
                    NSCursor.pop()
                }
        )
        .onAppear {
            localWidth = width
        }
        .onChange(of: width) { _, newValue in
            if !isDragging {
                localWidth = newValue
            }
        }
    }
}

