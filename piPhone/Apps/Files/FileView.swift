//
//  FileView.swift
//  piPhone
//
//  Created by Eris Leci on 1/12/26.
//

import SwiftUI

// MARK: - File Model
struct File: Identifiable, Equatable {
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

// MARK: - FileRow Model
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

// MARK: - Pick file screen
struct FilePickerScreen: View {
    @Binding var selectedFileId: String
    @Binding var options: [File]

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

// MARK: - Add File sheet
struct AddFileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var code: String = ""

    let onSave: (File) -> Void

    private var detectedLanguage: CodeLanguage {
        CodeLanguage.fromFilename(name)
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                Section("File Info") {
                    TextField("File name (e.g. notes.py)", text: $name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Code") {
                    RunestoneView(text: $code, language: detectedLanguage)
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

                        let newFile = File(
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
