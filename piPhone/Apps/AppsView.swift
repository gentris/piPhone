//
//  AppsView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct AppItem: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

import Foundation

struct FileOption: Identifiable, Equatable {
    let id: String
    var name: String
    var url: String
    var code: String

    init(id: String = UUID().uuidString, name: String, url: String, code: String = "") {
        self.id = id
        self.name = name
        self.url = url
        self.code = code
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
                                        .contentShape(.contextMenuPreview,
                                                      RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .contextMenu {
                                            Button { } label: { Label("Edit", systemImage: "pencil") }
                                            Button {
                                                let copy = AppItem(title: item.title, icon: item.icon)
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
                    Button { showAddSheet = true } label: { Image(systemName: "plus") }
                }
            }
            .alert("Delete app \"\(appPendingDelete?.title ?? "")\"?",
                   isPresented: $showDeleteAlert) {
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
                    // optional: dismiss when selecting
                    // dismiss()
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
                selectedFileId = newFile.id // auto-select the new file
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
        FileOption(id: "f1", name: "projects.pdf", url: "files://projects"),
        FileOption(id: "f2", name: "text.pdf", url: "files://invoices"),
        FileOption(id: "f3", name: "books.pdf", url: "https://drive.google.com/specs"),
        FileOption(id: "f4", name: "car.pdf", url: "https://notion.so/tasks")
    ]

    private let iconOptions: [String] = [
        "app.fill", "sparkles", "star.fill", "bolt.fill", "flame.fill",
        "timer", "bell.fill", "heart.fill", "bookmark.fill", "paperplane.fill",
        "camera.fill", "photo.fill", "music.note", "headphones", "gamecontroller.fill",
        "message.fill", "phone.fill", "envelope.fill", "map.fill", "location.fill",
        "cart.fill", "creditcard.fill", "dollarsign.circle.fill", "chart.bar.fill",
        "cloud.fill", "wifi", "lock.fill", "key.fill", "person.fill", "person.2.fill"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    private var selectedFileName: String {
        fileOptions.first(where: { $0.id == selectedFileId })?.name ?? "None"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("App Info") {
                    TextField("App name", text: $title)
                }

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

                Section("Icon") {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title2)
                            .scaleEffect(1.15)

                    }

                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(iconOptions, id: \.self) { name in
                                Button { icon = name } label: {
                                    Image(systemName: name)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, minHeight: 36)
                                        .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .frame(maxHeight: 222)
                }
            }
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

    var body: some View {
        NavigationStack {
            Form {
                Section("File Info") {
                    TextField("File name (e.g. notes.txt)", text: $name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Code") {
                    TextEditor(text: $code)
                        .frame(minHeight: 220)
                        .font(.system(.body, design: .monospaced))
                }
            }
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

                        // url can be whatever you want; this is a simple placeholder
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


#Preview {
    ContentView()
}
