//
//  AppsView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import Foundation
import Runestone
import SwiftUI
import TreeSitterJavaRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterPythonRunestone
import UIKit

struct AppItem: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

enum CodeLanguage: Equatable {
    case plainText
    case javaScript
    case python
    case java

    static func fromFilename(_ name: String) -> CodeLanguage {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let ext = (trimmed as NSString).pathExtension.lowercased()

        switch ext {
        case "js", "jsx", "mjs", "cjs":
            return .javaScript
        case "py":
            return .python
        case "java":
            return .java
        default:
            return .plainText
        }
    }
}

struct FileOption: Identifiable, Equatable {
    let id: String
    var name: String
    var url: String
    var code: String
    var language: CodeLanguage

    init(
        id: String = UUID().uuidString,
        name: String,
        url: String,
        code: String = "",
        language: CodeLanguage = .plainText
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.code = code
        self.language = language
    }
}

struct RunestoneEditorView: UIViewRepresentable {
    @Binding var text: String
    var language: CodeLanguage

    func makeUIView(context: Context) -> TextView {
        let tv = TextView()
        tv.editorDelegate = context.coordinator

        tv.theme = RunestoneTheme()
        tv.backgroundColor = UIColor.clear

        tv.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        tv.showLineNumbers = true
        tv.lineHeightMultiplier = 1.2
        tv.kern = 0.3

        tv.characterPairs = defaultPairs
        tv.indentStrategy = .space(length: 4)
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.smartQuotesType = .no
        tv.smartDashesType = .no
        tv.smartInsertDeleteType = .no
        tv.spellCheckingType = .no

        tv.text = text
        applyLanguage(to: tv, language: language)

        return tv
    }

    func updateUIView(_ tv: TextView, context: Context) {
        if tv.text != text {
            tv.text = text
        }

        if context.coordinator.lastLanguage != language {
            context.coordinator.lastLanguage = language
            applyLanguage(to: tv, language: language)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, lastLanguage: language)
    }

    final class Coordinator: NSObject, TextViewDelegate {
        var text: Binding<String>
        var lastLanguage: CodeLanguage

        init(text: Binding<String>, lastLanguage: CodeLanguage) {
            self.text = text
            self.lastLanguage = lastLanguage
        }
    }

    private func applyLanguage(to tv: TextView, language: CodeLanguage) {
        switch language {
        case .plainText:
            tv.setLanguageMode(PlainTextLanguageMode())

        case .javaScript:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .javaScript))

        case .python:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .python))

        case .java:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .java))
        }
    }
}

struct AppsView: View {
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newIcon = ""
    @State private var newFileId = "none"
    @State private var searchText = ""
    @State private var appPendingDelete: AppItem? = nil
    @State private var showDeleteAlert = false

    @State private var apps: [AppItem] = [
        .init(title: "UI change", icon: "photo"),
        .init(title: "Take a Break", icon: "timer"),
        .init(title: "Add new Task", icon: "map"),
        .init(title: "Add new Apple", icon: "phone"),
        .init(title: "Add new Ticket", icon: "map"),
        .init(title: "Should add a new Ticket", icon: "headphones"),
        .init(title: "Change Theme", icon: "envelope"),
        .init(title: "Phone details", icon: "phone"),
        .init(title: "Take that dollar", icon: "dollarsign"),
        .init(title: "CreditCard", icon: "creditcard"),
    ]

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 110))]
    }

    private var filteredApps: [AppItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return apps }
        return apps.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }

    private func addNewApp() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newItem = AppItem(title: trimmed, icon: newIcon)
        apps.append(newItem)

        newTitle = ""
        newIcon = ""
        newFileId = "none"
        showAddSheet = false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredApps) { item in
                            NavigationLink {
                                AppDetailView(item: item)
                            } label: {
                                VStack(spacing: 8) {
                                    AppCard(item: item)
                                        .contentShape(
                                            .contextMenuPreview,
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        )
                                        .contextMenu {
                                            Button {
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            Button {
                                                let copy = AppItem(
                                                    title: item.title, icon: item.icon)
                                                apps.append(copy)
                                            } label: {
                                                Label("Duplicate", systemImage: "doc.on.doc")
                                            }

                                            Button(role: .destructive) {
                                                appPendingDelete = item
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                        }

                                    Text(item.title)
                                        .font(.footnote)
                                        .foregroundStyle(Color(.label))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                        .frame(width: 90)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Apps")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search apps"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(
                "Delete app \"\(appPendingDelete?.title ?? "")\"?",
                isPresented: $showDeleteAlert
            ) {
                Button("Cancel", role: .cancel) {
                    appPendingDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let app = appPendingDelete {
                        apps.removeAll { $0.id == app.id }
                    }
                    appPendingDelete = nil
                }
            } message: {
                Text("This app will be removed.")
            }

            .sheet(isPresented: $showAddSheet) {
                AddAppSheet(
                    title: $newTitle,
                    icon: $newIcon,
                    selectedFileId: $newFileId,
                    onAdd: { addNewApp() }
                )
            }
        }
    }
}

struct AppCard: View {
    let item: AppItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator).opacity(0.35), lineWidth: 1)
                )

            Image(systemName: item.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color(.label))
        }
        .frame(width: 72, height: 72)
        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
    }
}

struct AppIconCell: View {
    let item: AppItem

    var body: some View {
        VStack(spacing: 8) {
            AppCard(item: item)

            Text(item.title)
                .font(.footnote)
                .foregroundStyle(Color(.label))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 90)
                .multilineTextAlignment(.center)
        }
    }
}

struct AppDetailView: View {
    let item: AppItem

    var body: some View {
        VStack(spacing: 16) {
            AppCard(item: item)
                .padding()

            Text("Detail screen for: \(item.title)")
                .font(.title3)

            Spacer()
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FileRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text("Choose a file:")
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct FilePickerScreen: View {
    @Binding var selectedFileId: String
    @Binding var options: [FileOption]

    @Environment(\.dismiss) private var dismiss
    @State private var showAddFileSheet = false

    var body: some View {
        List {
            ForEach(options) { opt in
                Button {
                    selectedFileId = (selectedFileId == opt.id) ? "none" : opt.id
                } label: {
                    HStack {
                        Text(opt.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        if opt.id == selectedFileId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.primary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("File")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddFileSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddFileSheet) {
            AddFileSheet { newFile in
                options.append(newFile)
                selectedFileId = newFile.id
            }
        }
    }
}

struct AddAppSheet: View {
    @Binding var title: String
    @Binding var icon: String
    @Binding var selectedFileId: String

    let onAdd: () -> Void

    @State private var fileOptions: [FileOption] = [
        FileOption(id: "f1", name: "projects.pdf", url: "files://projects")
    ]

    private let iconCategories: [(title: String, symbols: [String])] = [
        (
            "Communication",
            [
                "mic.fill", "message.fill", "phone.fill",
                "video.fill", "envelope.fill",
            ]
        ),
        (
            "Weather",
            [
                "sun.max.fill", "moon.fill",
                "cloud.fill", "cloud.rain.fill",
            ]
        ),
        (
            "Objects & Tools",
            [
                "folder.fill", "paperclip",
                "link", "book.fill",
                "trash.fill", "gearshape.fill",
                "eraser.fill", "graduationcap.fill",
                "ruler.fill", "backpack.fill",
            ]
        ),
        (
            "Devices",
            [
                "keyboard.fill", "printer.fill",
                "desktopcomputer", "macpro.gen2", "pc",
                "airtag.fill", "macpro.gen3.fill", "display",
                "iphone.gen2",
            ]
        ),
        (
            "Nature",
            [
                "globe.europe.africa", "sun.min.fill",
                "cloud.sun.fill", "sun.max.fill",
                "sunrise.fill", "moon.fill",
                "sparkles", "moon.stars",
                "cloud.fill", "cloud.heavyrain.fill",
                "wind", "snowflake", "leaf", "bolt",
            ]
        ),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    private var selectedFileName: String {
        fileOptions.first(where: { $0.id == selectedFileId })?.name ?? "None"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("File") {
                    NavigationLink {
                        FilePickerScreen(
                            selectedFileId: $selectedFileId,
                            options: $fileOptions
                        )
                    } label: {
                        FileRow(title: "File", value: selectedFileName)
                    }
                }

                Section("App Info") {
                    TextField("App name", text: $title)
                }

                Section("Icon") {

                    // Selected icon preview
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title2)
                            .scaleEffect(1.3)
                    }

                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 16) {

                            ForEach(iconCategories, id: \.title) { category in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.title)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.secondary)

                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(category.symbols, id: \.self) { name in
                                            Button {
                                                icon = name
                                            } label: {
                                                Image(systemName: name)
                                                    .font(.title)
                                                    .frame(maxWidth: .infinity, minHeight: 36)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(
                                                                name == icon
                                                                    ? Color.primary.opacity(0.15)
                                                                    : Color.clear)
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New App")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onAdd() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddFileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var code: String = ""

    let onSave: (FileOption) -> Void

    private var detectedLanguage: CodeLanguage {
        CodeLanguage.fromFilename(name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("File Info") {
                    TextField("File name (e.g. notes.py)", text: $name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Code") {
                    RunestoneEditorView(text: $code, language: detectedLanguage)
                        .frame(minHeight: 550)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }

                        let newFile = FileOption(
                            name: trimmed,
                            url: "files://\(trimmed)",
                            code: code
                        )
                        onSave(newFile)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct SimplePair: CharacterPair {
    let leading: String
    let trailing: String
}

private let defaultPairs: [CharacterPair] = [
    SimplePair(leading: "{", trailing: "}"),
    SimplePair(leading: "(", trailing: ")"),
    SimplePair(leading: "[", trailing: "]"),
    SimplePair(leading: "\"", trailing: "\""),
    SimplePair(leading: "'", trailing: "'"),
]

#Preview {
    ContentView()
}
