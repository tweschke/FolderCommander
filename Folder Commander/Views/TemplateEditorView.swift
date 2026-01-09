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
                HStack {
                    Text("Template Name:")
                        .frame(width: 120, alignment: .trailing)
                    TextField("Enter template name", text: $templateName)
                }
                .padding()
                
                Divider()
                
                // Mode selector
                Picker("Editor Mode", selection: $editorMode) {
                    Text("Visual Editor").tag(EditorMode.visual)
                    Text("Text Input").tag(EditorMode.text)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Divider()
                
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
            .navigationTitle(editingTemplate == nil ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
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
                        Text("No items yet. Click 'Add Item' to create your first folder or file.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    // Add to selected folder if one is selected and it's a folder, otherwise add to root container
                    if let selected = selectedItem, 
                       selected.type == .folder {
                        addItem(to: selected)
                    } else {
                        addItem(to: rootItem)
                    }
                }) {
                    Label(
                        selectedItem?.type == .folder 
                            ? "Add Child" 
                            : "Add Item",
                        systemImage: "plus.circle"
                    )
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    if let selected = selectedItem {
                        deleteItem(selected, from: &rootItem)
                        selectedItem = nil
                    }
                }) {
                    Label("Delete Selected", systemImage: "minus.circle")
                }
                .buttonStyle(.bordered)
                .disabled(selectedItem == nil)
                
                Spacer()
                
                // Show selected item info
                if let selected = selectedItem {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(selected.name)
                            .font(.caption)
                            .bold()
                        Text(selected.type == .folder ? "Folder" : "File")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
            .padding()
            .frame(width: 200)
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
            } label: {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                    Text(item.name)
                        .font(.system(size: 13))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = item
                    // Expand when selected
                    isExpanded = true
                }
                .contextMenu {
                    Button("Add Child") {
                        selectedItem = item
                        isExpanded = true
                        addChild(to: item)
                    }
                    Button("Edit") {
                        editingItem = item
                        showingItemEditor = true
                    }
                    if item.id != rootItem.id {
                        Button("Delete", role: .destructive) {
                            deleteItem(item, from: &rootItem)
                        }
                    }
                }
            }
        } else {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.gray)
                Text(item.name)
                    .font(.system(size: 13))
            }
            .padding(.leading, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedItem = item
            }
            .contextMenu {
                Button("Edit") {
                    editingItem = item
                    showingItemEditor = true
                }
                Button("Delete", role: .destructive) {
                    deleteItem(item, from: &rootItem)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter folder structure (use indentation for nesting):")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TextEditor(text: $textInput)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
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
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    Text("Folder").tag(ItemType.folder)
                    Text("File").tag(ItemType.file)
                }
                
                if type == .file {
                    Text("Content (optional):")
                        .font(.subheadline)
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
            }
            .padding()
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 500, height: type == .file ? 400 : 200)
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
