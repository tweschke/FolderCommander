# Architecture

High-level structure of Folder Commander.

## Overview

The app is a single-window SwiftUI macOS application with:

- A **sidebar** for navigation (Templates, Create Project, Backups).
- A **main content area** that shows the selected screen.
- **Templates** — list and preview; create/edit templates.
- **Create Project** — wizard to pick a template, name, location, and create folders.
- **Backups** — import/export all templates as JSON.

## Layers

| Layer   | Role |
|--------|------|
| **App** | `Folder_CommanderApp`, `ContentView` — entry point and root window. |
| **Views** | `MainView`, `TemplatesView`, `ProjectCreationView`, `SettingsView` (Backups), `TemplateEditorView`, and shared components in `Views/Components/`. |
| **Models** | `Template`, `FolderItem`, `TemplateStore`, `AppSettings` — data and persistence. |
| **Services** | `FileSystemService`, `TemplateParser`, `ErrorHandlingService`, `IconTinting` — file I/O, parsing, errors. |
| **Theme** | `AppTheme`, `ButtonStyles`, color/typography/spacing — design tokens and styles. |

## Key flows

- **Templates:** Stored in `TemplateStore` (UserDefaults). List and preview in `TemplatesView`; create/edit in `TemplateEditorView`; import/export in Backups (`SettingsView`).
- **Project creation:** User selects template, name, and directory; `FileSystemService` creates the folder structure; security-scoped access used for chosen directory.
- **Menu commands:** Handled via `NotificationCenter` from `AppMenuCommands`; `MainView` observes and updates selection or opens sheets.

## File layout (source)

```
Folder Commander/
├── Folder_CommanderApp.swift
├── ContentView.swift
├── Models/
├── Services/
├── Theme/
│   ├── AppTheme.swift
│   ├── ButtonStyles.swift
│   └── ColorExtensions.swift
├── Views/
│   ├── MainView.swift
│   ├── TemplatesView.swift
│   ├── ProjectCreationView.swift
│   ├── SettingsView.swift
│   ├── TemplateEditorView.swift
│   └── Components/
└── Assets.xcassets/
```

See [PROJECT_PLAN.md](PROJECT_PLAN.md) for feature details and [DEVELOPMENT.md](DEVELOPMENT.md) for build and test.
