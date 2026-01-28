//
//  AppMenuCommands.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 28/01/2026.
//

import SwiftUI
import AppKit

/// Standard macOS menu bar commands with keyboard shortcuts
struct AppMenuCommands: Commands {
    var body: some Commands {
        // File Menu
        CommandGroup(replacing: .newItem) {
            Button("New Template") {
                // This will be handled by the view that receives the command
                NotificationCenter.default.post(name: .createNewTemplate, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        
        CommandGroup(after: .newItem) {
            Button("New Project") {
                NotificationCenter.default.post(name: .createNewProject, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }
        
        CommandGroup(replacing: .importExport) {
            Button("Import Template...") {
                NotificationCenter.default.post(name: .importTemplate, object: nil)
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
            
            Button("Export Template...") {
                NotificationCenter.default.post(name: .exportTemplate, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }
        
        // Edit Menu
        CommandGroup(replacing: .undoRedo) {
            // Undo/Redo can be added when implemented
        }
        
        CommandGroup(after: .textEditing) {
            Button("Select All") {
                NotificationCenter.default.post(name: .selectAll, object: nil)
            }
            .keyboardShortcut("a", modifiers: .command)
        }
        
        // View Menu
        CommandGroup(replacing: .toolbar) {
            // Toolbar visibility can be added if needed
        }
        
        // Help Menu
        CommandGroup(replacing: .help) {
            Button("Folder Commander Help") {
                // Open help documentation
                if let url = URL(string: "https://help.foldercommander.app") {
                    NSWorkspace.shared.open(url)
                }
            }
            .keyboardShortcut("?", modifiers: .command)
            
            Divider()
            
            Button("About Folder Commander") {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
        }
        
        // Settings Menu (macOS 13+)
        CommandGroup(after: .appSettings) {
            Button("Settings...") {
                NotificationCenter.default.post(name: .openSettings, object: nil)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let createNewTemplate = Notification.Name("createNewTemplate")
    static let createNewProject = Notification.Name("createNewProject")
    static let importTemplate = Notification.Name("importTemplate")
    static let exportTemplate = Notification.Name("exportTemplate")
    static let selectAll = Notification.Name("selectAll")
    static let openSettings = Notification.Name("openSettings")
}
