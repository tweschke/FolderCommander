//
//  TemplateTreeView.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 09/01/2026.
//

import SwiftUI

struct TemplateTreeView: View {
    let item: FolderItem
    @State private var isExpanded: Bool = true
    
    var body: some View {
        if item.type == .folder {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let children = item.children, !children.isEmpty {
                    ForEach(children) { child in
                        TemplateTreeView(item: child)
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
            }
        } else {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.gray)
                Text(item.name)
                    .font(.system(size: 13))
            }
            .padding(.leading, 16)
        }
    }
}

#Preview {
    TemplateTreeView(item: FolderItem.folder(name: "Project", children: [
        .folder(name: "Code", children: [
            .file(name: "main.swift"),
            .folder(name: "src", children: [])
        ]),
        .file(name: "README.md")
    ]))
    .padding()
}
