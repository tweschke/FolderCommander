//
//  TemplateEditorView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct TemplateEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateStore: TemplateStore
    let editingTemplate: Template?
    
    @State private var templateName: String
    @State private var rootItem: FolderItem
    @State private var editorMode: EditorMode = .visual
    @State private var textInput: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedItem: FolderItem?
    @State private var editingItem: FolderItem?
    @State private var showingItemEditor = false
    
    enum EditorMode {
        case visual
        case text
    }
    
    init(templateStore: TemplateStore, editingTemplate: Template? = nil) {
        self.templateStore = templateStore
        self.editingTemplate = editingTemplate
        
        if let template = editingTemplate {
            _templateName = State(initialValue: template.name)
            _rootItem = State(initialValue: template.rootItem)
            _textInput = State(initialValue: Self.itemToText(template.rootItem))
        } else {
            _templateName = State(initialValue: "")
            // Create root container (not shown in UI, just holds children)
            _rootItem = State(initialValue: FolderItem.folder(name: "", children: []))
            _textInput = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Template name input
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Template Name")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Enter template name", text: $templateName)
                        .textFieldStyle(.plain)
                        .font(AppTypography.title3)
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(
                                            templateName.isEmpty ? AppColors.border : AppColors.primary.opacity(0.5),
                                            lineWidth: 2
                                        )
                                )
                        )
                        .appShadow(AppShadow.small)
                }
                .padding(AppSpacing.lg)
                .background(AppColors.secondaryBackground)
                
                Divider()
                    .background(AppColors.border)
                
                // Mode selector
                Picker("Editor Mode", selection: $editorMode) {
                    Label("Visual Editor", systemImage: "square.grid.2x2").tag(EditorMode.visual)
                    Label("Text Input", systemImage: "text.alignleft").tag(EditorMode.text)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.secondaryBackground)
                
                Divider()
                    .background(AppColors.border)
                
                // Editor content
                if editorMode == .visual {
                    VisualEditorView(
                        rootItem: $rootItem,
                        selectedItem: $selectedItem,
                        editingItem: $editingItem,
                        showingItemEditor: $showingItemEditor
                    )
                } else {
                    TextEditorView(textInput: $textInput, rootItem: $rootItem)
                }
            }
            .background(AppColors.background)
            .navigationTitle(editingTemplate == nil ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { saveTemplate() }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                    }
                    .primaryButton(enabled: !templateName.isEmpty)
                    .disabled(templateName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(item: $editingItem) { item in
                ItemEditorView(item: item, rootItem: $rootItem, editingItem: $editingItem)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func saveTemplate() {
        if editorMode == .text {
            // Parse text input and wrap in root container
            do {
                let parsedItem = try TemplateParser.parse(textInput)
                // Wrap parsed item in a root container (empty name)
                if parsedItem.name.isEmpty {
                    // If parsed item has no name, use its children directly
                    rootItem = FolderItem.folder(name: "", children: parsedItem.children ?? [])
                } else {
                    // If parsed item has a name, wrap it in the root container
                    rootItem = FolderItem.folder(name: "", children: [parsedItem])
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
                return
            }
        }
        
        let template = Template(
            id: editingTemplate?.id ?? UUID(),
            name: templateName,
            rootItem: rootItem,
            createdDate: editingTemplate?.createdDate ?? Date(),
            modifiedDate: Date()
        )
        
        if editingTemplate != nil {
            templateStore.updateTemplate(template)
        } else {
            templateStore.addTemplate(template)
        }
        
        dismiss()
    }
    
    // Convert FolderItem to text format for text editor
    private static func itemToText(_ item: FolderItem) -> String {
        var lines: [String] = []
        func buildText(_ item: FolderItem, level: Int = 0) {
            // Skip root item if it has no name (it's just a container)
            if !item.name.isEmpty || level > 0 {
                let indent = String(repeating: "  ", count: level)
                lines.append("\(indent)\(item.name)")
            }
            if let children = item.children {
                for child in children {
                    buildText(child, level: item.name.isEmpty ? level : level + 1)
                }
            }
        }
        buildText(item)
        return lines.joined(separator: "\n")
    }
}

struct VisualEditorView: View {
    @Binding var rootItem: FolderItem
    @Binding var selectedItem: FolderItem?
    @Binding var editingItem: FolderItem?
    @Binding var showingItemEditor: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Tree view - show children of rootItem directly, not rootItem itself
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let children = rootItem.children, !children.isEmpty {
                        ForEach(children) { child in
                            EditableTreeView(
                                item: child,
                                selectedItem: $selectedItem,
                                editingItem: $editingItem,
                                showingItemEditor: $showingItemEditor,
                                rootItem: $rootItem
                            )
                        }
                    } else {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 48, weight: .ultraLight))
                                .foregroundStyle(AppColors.textTertiary)
                            
                            Text("No items yet")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("Click 'Add Item' to create your first folder or file")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppSpacing.xl)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Action buttons
            VStack(spacing: AppSpacing.md) {
                Button(action: {
                    // Add to selected folder if one is selected and it's a folder, otherwise add to root container
                    if let selected = selectedItem, 
                       selected.type == .folder {
                        addItem(to: selected)
                    } else {
                        addItem(to: rootItem)
                    }
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text(selectedItem?.type == .folder ? "Add Child" : "Add Item")
                    }
                }
                .primaryButton()
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    if let selected = selectedItem {
                        deleteItem(selected, from: &rootItem)
                        selectedItem = nil
                    }
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "minus.circle.fill")
                        Text("Delete Selected")
                    }
                }
                .destructiveButton(enabled: selectedItem != nil)
                .disabled(selectedItem == nil)
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Show selected item info
                if let selected = selectedItem {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: selected.type == .folder ? "folder.fill" : "doc.fill")
                                .foregroundStyle(selected.type == .folder ? AppColors.primaryGradient : LinearGradient(colors: [AppColors.textSecondary, AppColors.textTertiary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .font(.system(size: 16))
                            
                            Text("Selected")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text(selected.name)
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(selected.type == .folder ? "Folder" : "File")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }
            }
            .padding(AppSpacing.lg)
            .frame(width: 220)
            .background(AppColors.secondaryBackground)
        }
    }
    
    private func addItem(to parent: FolderItem) {
        let newItem = FolderItem.folder(name: "New Folder", children: [])
        editingItem = newItem
        showingItemEditor = true
        
        // Add to root if parent is root
        if parent.id == rootItem.id {
            if rootItem.children == nil {
                rootItem.children = []
            }
            rootItem.children?.append(newItem)
        } else {
            addItemToParent(newItem, parentId: parent.id, in: &rootItem)
        }
    }
    
    private func addItemToParent(_ item: FolderItem, parentId: UUID, in root: inout FolderItem) {
        if root.id == parentId {
            if root.children == nil {
                root.children = []
            }
            root.children?.append(item)
        } else if let children = root.children {
            for index in children.indices {
                addItemToParent(item, parentId: parentId, in: &root.children![index])
            }
        }
    }
    
    private func deleteItem(_ item: FolderItem, from root: inout FolderItem) {
        if let children = root.children {
            root.children = children.filter { $0.id != item.id }
            for index in root.children!.indices {
                deleteItem(item, from: &root.children![index])
            }
        }
    }
}

struct EditableTreeView: View {
    let item: FolderItem
    @Binding var selectedItem: FolderItem?
    @Binding var editingItem: FolderItem?
    @Binding var showingItemEditor: Bool
    @Binding var rootItem: FolderItem
    @State private var isExpanded = true
    
    var body: some View {
        if item.type == .folder {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let children = item.children {
                    ForEach(children) { child in
                        EditableTreeView(
                            item: child,
                            selectedItem: $selectedItem,
                            editingItem: $editingItem,
                            showingItemEditor: $showingItemEditor,
                            rootItem: $rootItem
                        )
                        .padding(.leading, 16)
                    }
                }
            }             label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: isExpanded ? "folder.fill" : "folder")
                        .foregroundStyle(AppColors.primaryGradient)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(item.name)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.vertical, AppSpacing.xs)
                .padding(.horizontal, AppSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .fill(selectedItem?.id == item.id ? AppColors.primary.opacity(0.15) : Color.clear)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = item
                    // Expand when selected
                    isExpanded = true
                }
                .contextMenu {
                    Button(action: {
                        selectedItem = item
                        isExpanded = true
                        addChild(to: item)
                    }) {
                        Label("Add Child", systemImage: "plus.circle")
                    }
                    Button(action: {
                        editingItem = item
                        showingItemEditor = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    if item.id != rootItem.id {
                        Button(role: .destructive, action: {
                            deleteItem(item, from: &rootItem)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        } else {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.textSecondary, AppColors.textTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 16, weight: .medium))
                
                Text(item.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.leading, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(selectedItem?.id == item.id ? AppColors.primary.opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedItem = item
            }
            .contextMenu {
                Button(action: {
                    editingItem = item
                    showingItemEditor = true
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: {
                    deleteItem(item, from: &rootItem)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private func addChild(to parent: FolderItem) {
        let newItem = FolderItem.folder(name: "New Folder", children: [])
        editingItem = newItem
        showingItemEditor = true
        addItemToParent(newItem, parentId: parent.id, in: &rootItem)
    }
    
    private func addItemToParent(_ item: FolderItem, parentId: UUID, in root: inout FolderItem) {
        if root.id == parentId {
            if root.children == nil {
                root.children = []
            }
            root.children?.append(item)
        } else if let children = root.children {
            for index in children.indices {
                addItemToParent(item, parentId: parentId, in: &root.children![index])
            }
        }
    }
    
    private func deleteItem(_ item: FolderItem, from root: inout FolderItem) {
        if let children = root.children {
            root.children = children.filter { $0.id != item.id }
            for index in root.children!.indices {
                deleteItem(item, from: &root.children![index])
            }
        }
    }
}

struct TextEditorView: View {
    @Binding var textInput: String
    @Binding var rootItem: FolderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(AppColors.primaryGradient)
                    .font(.system(size: 18))
                
                Text("Enter folder structure (use indentation for nesting):")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            
            TextEditor(text: $textInput)
                .font(.system(.body, design: .monospaced))
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(AppColors.tertiaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)
        }
        .background(AppColors.background)
        .onChange(of: textInput) { _, newValue in
            // Try to parse and update rootItem in real-time
            if let parsed = try? TemplateParser.parse(newValue) {
                rootItem = parsed
            }
        }
    }
}

struct ItemEditorView: View {
    let item: FolderItem
    @Binding var rootItem: FolderItem
    @Binding var editingItem: FolderItem?
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var type: ItemType
    @State private var content: String
    
    init(item: FolderItem, rootItem: Binding<FolderItem>, editingItem: Binding<FolderItem?>) {
        self.item = item
        self._rootItem = rootItem
        self._editingItem = editingItem
        _name = State(initialValue: item.name)
        _type = State(initialValue: item.type)
        _content = State(initialValue: item.content ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Name")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Item name", text: $name)
                        .textFieldStyle(.plain)
                        .font(AppTypography.body)
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(
                                            name.isEmpty ? AppColors.border : AppColors.primary.opacity(0.5),
                                            lineWidth: 2
                                        )
                                )
                        )
                        .appShadow(AppShadow.small)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Type")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Picker("Type", selection: $type) {
                        Label("Folder", systemImage: "folder.fill").tag(ItemType.folder)
                        Label("File", systemImage: "doc.fill").tag(ItemType.file)
                    }
                    .pickerStyle(.segmented)
                }
                
                if type == .file {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Content (optional)")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextEditor(text: $content)
                            .font(.system(.body, design: .monospaced))
                            .frame(height: 200)
                            .padding(AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .fill(AppColors.tertiaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            )
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppColors.background)
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { saveItem() }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                    }
                    .primaryButton(enabled: !name.isEmpty)
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 500, height: type == .file ? 450 : 250)
    }
    
    private func saveItem() {
        updateItem(item, name: name, type: type, content: type == .file ? content : nil, in: &rootItem)
        editingItem = nil
        dismiss()
    }
    
    private func updateItem(_ item: FolderItem, name: String, type: ItemType, content: String?, in root: inout FolderItem) {
        if root.id == item.id {
            root.name = name
            root.type = type
            root.content = content
            if type == .folder && root.children == nil {
                root.children = []
            } else if type == .file {
                root.children = nil
            }
        } else if let children = root.children {
            for index in children.indices {
                updateItem(item, name: name, type: type, content: content, in: &root.children![index])
            }
        }
    }
}

#Preview {
    TemplateEditorView(templateStore: TemplateStore())
}
