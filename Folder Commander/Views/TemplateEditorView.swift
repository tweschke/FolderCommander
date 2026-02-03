//
//  TemplateEditorView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

// Apple's default folder blue color (consistent across all views)
private let appleFolderBlue = Color(red: 0.33, green: 0.67, blue: 0.95)

struct TemplateEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateStore: TemplateStore
    @ObservedObject var appSettings: AppSettings
    let editingTemplate: Template?
    
    @State private var templateName: String
    @State private var rootItem: FolderItem
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedItem: FolderItem?
    @State private var editingItem: FolderItem?
    @State private var showingItemEditor = false
    
    init(templateStore: TemplateStore, editingTemplate: Template? = nil, appSettings: AppSettings) {
        self.templateStore = templateStore
        self.appSettings = appSettings
        self.editingTemplate = editingTemplate
        
        if let template = editingTemplate {
            _templateName = State(initialValue: template.name)
            _rootItem = State(initialValue: template.rootItem)
        } else {
            _templateName = State(initialValue: "")
            // Create root container (not shown in UI, just holds children)
            _rootItem = State(initialValue: FolderItem.folder(name: "", children: []))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                // Template name input
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Template Details",
                        systemImage: "pencil.and.outline",
                        subtitle: "Name and structure settings"
                    )
                    
                    Text("Template Name")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("Enter template name", text: $templateName)
                        .textFieldStyle(.plain)
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(
                                            templateName.isEmpty
                                                ? AppColors.border
                                                : AppColors.accent.opacity(0.5),
                                            lineWidth: 2
                                        )
                                )
                        )
                        .shadow(
                            color: templateName.isEmpty
                                ? Color.clear
                                : AppColors.accent.opacity(0.1),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                        .appShadow(AppShadow.small)
                        .accessibilityLabel("Template name")
                        .accessibilityHint("Enter a name for this template")
                }
                .padding(AppSpacing.lg)
                .dashboardCardStyle()
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                
                // Editor content
                VisualEditorView(
                    rootItem: $rootItem,
                    selectedItem: $selectedItem,
                    editingItem: $editingItem,
                    showingItemEditor: $showingItemEditor,
                    appSettings: appSettings
                )
            }
            .background(AppColors.contentGradient)
            .navigationTitle(editingTemplate == nil ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                    .toolbarItemCentered()
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
                    .toolbarItemCentered()
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(item: $editingItem) { item in
                ItemEditorView(item: item, rootItem: $rootItem, editingItem: $editingItem, appSettings: appSettings)
            }
        }
        .frame(minWidth: 800)
        .frame(minHeight: 760)
    }
    
    private func saveTemplate() {
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
    
}

struct VisualEditorView: View {
    @Binding var rootItem: FolderItem
    @Binding var selectedItem: FolderItem?
    @Binding var editingItem: FolderItem?
    @Binding var showingItemEditor: Bool
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            // Tree view - show children of rootItem directly, not rootItem itself
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(
                    title: "Structure",
                    systemImage: "list.bullet.rectangle",
                    subtitle: "Folders and files"
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if let children = rootItem.children, !children.isEmpty {
                            ForEach(children) { child in
                                EditableTreeView(
                                    item: child,
                                    selectedItem: $selectedItem,
                                    editingItem: $editingItem,
                                    showingItemEditor: $showingItemEditor,
                                    rootItem: $rootItem,
                                    appSettings: appSettings
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
                            .frame(maxWidth: .infinity, minHeight: 240)
                            .padding(AppSpacing.xl)
                        }
                    }
                    .padding(.vertical, AppSpacing.sm)
                }
            }
            .padding(AppSpacing.lg)
            .dashboardCardStyle()
            .frame(maxWidth: .infinity)
            
            // Action buttons
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(
                    title: "Actions",
                    systemImage: "bolt.fill",
                    subtitle: "Add or delete items"
                )
                
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
                    .frame(maxWidth: .infinity)
                }
                .primaryButton()
                
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
                    .frame(maxWidth: .infinity)
                }
                .destructiveButton(enabled: selectedItem != nil)
                .disabled(selectedItem == nil)
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Selection", systemImage: "cursorarrow.rays", compact: true)
                    
                    if let selected = selectedItem {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: selected.type == .folder ? "folder.fill" : "doc.fill")
                                .foregroundStyle(
                                    selected.type == .folder
                                        ? AnyShapeStyle(selected.getColor() ?? appleFolderBlue)
                                        : AnyShapeStyle(LinearGradient(colors: [AppColors.textSecondary, AppColors.textTertiary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .font(.system(size: 18, weight: .semibold))
                            
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
                    } else {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "cursorarrow.rays")
                                .foregroundStyle(AppColors.textTertiary)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("No item selected")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text("Select a folder or file to see details.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .dashboardCardStyle()
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .frame(width: 240)
            .dashboardCardStyle()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
        .background(AppColors.contentGradient)
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
    @ObservedObject var appSettings: AppSettings
    @State private var isExpanded = true
    let level: Int

    private let disclosureIndicatorWidth: CGFloat = 12

    init(
        item: FolderItem,
        selectedItem: Binding<FolderItem?>,
        editingItem: Binding<FolderItem?>,
        showingItemEditor: Binding<Bool>,
        rootItem: Binding<FolderItem>,
        appSettings: AppSettings,
        level: Int = 0
    ) {
        self.item = item
        self._selectedItem = selectedItem
        self._editingItem = editingItem
        self._showingItemEditor = showingItemEditor
        self._rootItem = rootItem
        self.appSettings = appSettings
        self.level = level
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            treeRow
                .padding(.leading, CGFloat(level) * AppSpacing.md)

            if item.type == .folder, isExpanded, let children = item.children {
                ForEach(children) { child in
                    EditableTreeView(
                        item: child,
                        selectedItem: $selectedItem,
                        editingItem: $editingItem,
                        showingItemEditor: $showingItemEditor,
                        rootItem: $rootItem,
                        appSettings: appSettings,
                        level: level + 1
                    )
                }
            }
        }
    }

    private var treeRow: some View {
        HStack(spacing: AppSpacing.sm) {
            disclosureIndicator
            rowContent
        }
    }

    @ViewBuilder
    private var disclosureIndicator: some View {
        if item.type == .folder {
            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(width: disclosureIndicatorWidth, alignment: .center)
        } else {
            Color.clear
                .frame(width: disclosureIndicatorWidth, height: 1)
        }
    }

    private var rowContent: some View {
        HStack(spacing: AppSpacing.sm) {
            rowIcon
            Text(item.name)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(selectedItem?.id == item.id ? AnyShapeStyle(AppColors.selectedGlowGradient) : AnyShapeStyle(Color.clear))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .stroke(
                            selectedItem?.id == item.id ? AppColors.accent.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedItem = item
            if item.type == .folder {
                isExpanded = true
            }
        }
        .contextMenu {
            if item.type == .folder {
                Button(action: {
                    selectedItem = item
                    isExpanded = true
                    addChild(to: item)
                }) {
                    Label("Add Child", systemImage: "plus.circle")
                }
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

    @ViewBuilder
    private var rowIcon: some View {
        if item.type == .folder {
            let iconName = item.getIconName() ?? (isExpanded ? "folder.fill" : "folder")
            Image(systemName: iconName)
                .foregroundStyle(
                    item.color != nil
                        ? AnyShapeStyle(item.getColor() ?? appleFolderBlue)
                        : AnyShapeStyle(appleFolderBlue)
                )
                .font(.system(size: 18, weight: .semibold))
        } else {
            Image(systemName: "doc.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.textPrimary.opacity(0.8),
                            AppColors.textSecondary.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.system(size: 18, weight: .semibold))
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

struct ItemEditorView: View {
    let item: FolderItem
    @Binding var rootItem: FolderItem
    @Binding var editingItem: FolderItem?
    @ObservedObject var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var type: ItemType
    @State private var content: String
    @State private var color: String?
    @State private var icon: String?
    
    init(item: FolderItem, rootItem: Binding<FolderItem>, editingItem: Binding<FolderItem?>, appSettings: AppSettings) {
        self.item = item
        self._rootItem = rootItem
        self._editingItem = editingItem
        self.appSettings = appSettings
        _name = State(initialValue: item.name)
        _type = State(initialValue: item.type)
        _content = State(initialValue: item.content ?? "")
        _color = State(initialValue: item.color)
        _icon = State(initialValue: item.icon)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        SectionHeader(title: "Basics", systemImage: "pencil", subtitle: "Name and type")
                        
                        Text("Name")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextField("Item name", text: $name)
                            .textFieldStyle(.plain)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .fill(AppColors.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(
                                                name.isEmpty
                                                    ? AppColors.border
                                                    : AppColors.accent.opacity(0.5),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .shadow(
                                color: name.isEmpty
                                    ? Color.clear
                                    : AppColors.accent.opacity(0.1),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                            .appShadow(AppShadow.small)
                        
                        Text("Type")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Picker("Type", selection: $type) {
                            Label("Folder", systemImage: "folder.fill").tag(ItemType.folder)
                            Label("File", systemImage: "doc.fill").tag(ItemType.file)
                        }
                        .pickerStyle(.segmented)
                        .tint(AppColors.accent)
                    }
                    .padding(AppSpacing.lg)
                    .dashboardCardStyle()
                    
                    if type == .file {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            SectionHeader(title: "File Content", systemImage: "doc.plaintext", subtitle: "Optional text")
                            
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
                        .padding(AppSpacing.lg)
                        .dashboardCardStyle()
                    }
                    
                    if type == .folder {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            SectionHeader(title: "Folder Appearance", systemImage: "paintpalette.fill", subtitle: "Color and icon")
                            
                            FolderColorPicker(
                                selectedColorHex: $color,
                                defaultColorHex: nil
                            )
                            
                            FolderIconPicker(selectedIconName: $icon)
                        }
                        .padding(AppSpacing.lg)
                        .dashboardCardStyle()
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.contentGradient)
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tertiaryButton()
                    .toolbarItemCentered()
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
                    .toolbarItemCentered()
                }
            }
        }
        .frame(width: 600)
        .frame(minHeight: 600)
    }
    
    
    private func saveItem() {
        updateItem(item, name: name, type: type, content: type == .file ? content : nil, color: type == .folder ? color : nil, icon: type == .folder ? icon : nil, in: &rootItem)
        editingItem = nil
        dismiss()
    }
    
    private func updateItem(_ item: FolderItem, name: String, type: ItemType, content: String?, color: String?, icon: String?, in root: inout FolderItem) {
        if root.id == item.id {
            root.name = name
            root.type = type
            root.content = content
            root.color = color
            root.icon = icon
            if type == .folder && root.children == nil {
                root.children = []
            } else if type == .file {
                root.children = nil
            }
        } else if let children = root.children {
            for index in children.indices {
                updateItem(item, name: name, type: type, content: content, color: color, icon: icon, in: &root.children![index])
            }
        }
    }
}

#Preview {
    TemplateEditorView(templateStore: TemplateStore(), appSettings: AppSettings())
}
