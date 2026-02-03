# Folder Commander - Project Plan & Current State

**Last Updated:** January 9, 2026  
**Status:** Pre-UAT Testing  
**Version:** 1.0

---

## 📋 Project Overview

Folder Commander is a macOS application built with SwiftUI that allows users to:
- Create and manage folder structure templates
- Generate projects from templates with a single click
- Import/export templates as JSON files
- Visualize folder structures before creation

---

## ✨ Current Features

### 1. Template Management
- **Create Templates**: Visual editor or text-based input
- **Edit Templates**: Modify existing templates
- **Delete Templates**: Remove unwanted templates
- **Export Templates**: Save templates as JSON files
- **Import Templates**: Load templates from JSON files

### 2. Project Creation Wizard
Multi-step wizard for creating projects:
1. **Select Template**: Choose from available templates
2. **Enter Project Name**: Specify the root folder name
3. **Select Location**: Choose destination directory
4. **Preview**: Review structure before creation
5. **Create**: Generate the folder structure

### 3. Visual Editor
- Tree-based visual editor for building folder structures
- Add folders and files
- Edit item properties (name, type, content)
- Delete items
- Context menu support

### 4. Text Editor
- Text-based input for quick template creation
- Indentation-based nesting
- Real-time parsing and validation

---

## 🎨 Design System

### Color Palette
- **Primary**: Modern vibrant blues (RGB: 0.2, 0.4, 0.9)
- **Accent**: Purple tones (RGB: 0.5, 0.3, 0.9)
- **Success**: Green tones (RGB: 0.2, 0.7, 0.4)
- **Destructive**: Red tones (RGB: 0.9, 0.25, 0.3)
- **Backgrounds**: System colors with opacity variations

### Typography
- Uses SF Rounded design for modern, friendly appearance
- Consistent font hierarchy:
  - Large Title (Bold)
  - Title (Semibold)
  - Headline (Semibold)
  - Body (Regular/Semibold)
  - Caption (Regular)

### Button Styles
1. **Primary**: Gradient buttons with shadows (main actions)
2. **Secondary**: Outlined buttons with subtle backgrounds
3. **Tertiary**: Minimal text buttons
4. **Destructive**: Red gradient for delete actions

### Visual Effects
- Card-based layouts with shadows
- Gradient backgrounds
- Spring animations on interactions
- Glass/material effects
- Consistent spacing system (xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48)

---

## 🏗️ Architecture

### File Structure
```
Folder Commander/
├── Models/
│   ├── Template.swift          # Template data model
│   ├── FolderItem.swift        # Folder/File item model
│   └── TemplateStore.swift     # Template persistence & management
├── Services/
│   ├── FileSystemService.swift # File system operations
│   └── TemplateParser.swift    # Text-to-template parsing
├── Views/
│   ├── MainView.swift          # Main application view
│   ├── ProjectCreationView.swift # Project creation wizard
│   ├── TemplateEditorView.swift  # Template editor
│   └── Components/
│       └── TemplateTreeView.swift # Tree visualization
├── Theme/
│   ├── AppTheme.swift          # Color system & design tokens
│   └── ButtonStyles.swift      # Custom button styles
└── ContentView.swift           # Root view
```

### Key Components

#### Template Model
- `id`: UUID
- `name`: String
- `rootItem`: FolderItem (tree structure)
- `createdDate`: Date
- `modifiedDate`: Date

#### FolderItem Model
- `id`: UUID
- `name`: String
- `type`: ItemType (.folder or .file)
- `children`: [FolderItem]? (optional, only for folders)
- `content`: String? (optional, only for files)

#### TemplateStore
- ObservableObject managing template persistence
- CRUD operations for templates
- JSON import/export functionality
- UserDefaults storage

---

## 🧪 UAT Testing Checklist

### Template Management
- [ ] Create a new template using visual editor
- [ ] Create a new template using text editor
- [ ] Edit an existing template
- [ ] Delete a template
- [ ] Export a template to JSON
- [ ] Import a template from JSON
- [ ] Verify template list updates correctly
- [ ] Test with empty template list

### Project Creation
- [ ] Complete full project creation wizard
- [ ] Navigate back/forward through steps
- [ ] Cancel project creation
- [ ] Create project with nested folder structure
- [ ] Create project with files containing content
- [ ] Verify project is created in correct location
- [ ] Test "Show in Finder" functionality
- [ ] Test error handling (invalid paths, permissions, etc.)

### Visual Editor
- [ ] Add folder to root
- [ ] Add file to root
- [ ] Add child to folder
- [ ] Edit item name
- [ ] Edit item type (folder ↔ file)
- [ ] Add content to file
- [ ] Delete item
- [ ] Select items
- [ ] Expand/collapse folders
- [ ] Context menu actions

### Text Editor
- [ ] Enter folder structure with indentation
- [ ] Verify real-time parsing
- [ ] Test with invalid syntax
- [ ] Switch between visual and text editor
- [ ] Verify data persistence when switching modes

### UI/UX
- [ ] Verify all buttons have proper styling
- [ ] Check button states (enabled/disabled)
- [ ] Verify animations are smooth
- [ ] Test empty states display correctly
- [ ] Verify color scheme consistency
- [ ] Check typography hierarchy
- [ ] Test on different window sizes
- [ ] Verify dark mode compatibility (if applicable)

### Edge Cases
- [ ] Template with very long names
- [ ] Template with deep nesting (10+ levels)
- [ ] Template with many items (100+)
- [ ] Project name with special characters
- [ ] Destination path with spaces/special characters
- [ ] Create project in read-only location
- [ ] Import malformed JSON
- [ ] Export/import round-trip verification

---

## 🐛 Known Issues / Considerations

### Current Limitations
1. **No template validation**: Templates can be saved with empty names or invalid structures
2. **No undo/redo**: Actions cannot be undone in the editor
3. **No template search/filter**: Large template lists may be hard to navigate
4. **No template categories/tags**: No organization system for templates
5. **No project templates**: Cannot save project configurations for reuse
6. **Limited error messages**: Some errors may not be user-friendly
7. **No file content preview**: Cannot preview file contents in templates
8. **No drag-and-drop**: Cannot reorder items in visual editor

### Future Enhancements (Post-UAT)
- [ ] Template validation and error checking
- [ ] Undo/redo functionality
- [ ] Template search and filtering
- [ ] Template categories/tags
- [ ] Drag-and-drop reordering
- [ ] File content preview
- [ ] Template versioning
- [ ] Project templates (save project configs)
- [ ] Keyboard shortcuts
- [ ] Template sharing/cloud sync
- [ ] Batch operations (create multiple projects)
- [ ] Template marketplace/community templates

---

## 📝 Technical Notes

### Dependencies
- SwiftUI (macOS 13.0+)
- UniformTypeIdentifiers (for file import/export)
- AppKit (for file dialogs)

### Storage
- Templates stored in UserDefaults
- JSON format for import/export
- File system operations use async/await

### Performance Considerations
- Template parsing is synchronous (may block UI for large templates)
- File creation uses async operations
- Tree rendering may slow with very deep structures

### Security
- File system access requires user permission
- Security-scoped resources used for file access
- No network operations (offline-first)

---

## 🎯 UAT Focus Areas

1. **User Flow**: Can users complete core tasks without confusion?
2. **Visual Design**: Is the modern design system effective and appealing?
3. **Error Handling**: Are errors clear and actionable?
4. **Performance**: Does the app feel responsive?
5. **Edge Cases**: How does the app handle unusual inputs?
6. **Consistency**: Is the UI consistent across all views?

---

## 📞 Support & Documentation

### For Testers
- Report issues with: template name, steps to reproduce, expected vs actual behavior
- Include screenshots for UI issues
- Note macOS version and system specs

### For Developers
- Check console logs for errors
- Review TemplateStore for data persistence issues
- Verify FileSystemService for file operation problems

---

## 🚀 Deployment Checklist (Post-UAT)

- [ ] Fix all critical bugs found in UAT
- [ ] Address high-priority UX issues
- [ ] Code review and cleanup
- [ ] Performance optimization
- [ ] Final design polish
- [ ] Documentation completion
- [ ] App icon and assets finalization
- [ ] Build configuration for release
- [ ] Notarization (if required)
- [ ] Distribution preparation

---

**End of Document**
