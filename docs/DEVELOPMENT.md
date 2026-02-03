# Development

Setup, build, and test for Folder Commander.

## Requirements

- Xcode 15+ (macOS 14.0 SDK)
- macOS 14.0+ for running the app

## Setup

1. Clone the repository.
2. Open `Folder Commander.xcodeproj` in Xcode.
3. No external dependencies; the project uses only system frameworks (SwiftUI, AppKit, UniformTypeIdentifiers).

## Build

- **Run:** Select the **Folder Commander** scheme and press ⌘R.
- **Archive:** Product → Archive (for distribution).

## Tests

- **Unit tests:** Folder CommanderTests target — ⌘U or Product → Test.
- **UI tests:** Folder CommanderUITests target — run the UI test scheme.

## Code layout

- **Folder Commander/** — App source.
  - **Models/** — Data models (Template, FolderItem, TemplateStore, AppSettings).
  - **Services/** — File system, template parsing, error handling, icon tinting.
  - **Theme/** — Colors, typography, spacing, button styles.
  - **Views/** — Main views and reusable components.

See [ARCHITECTURE.md](ARCHITECTURE.md) for a high-level structure overview.
