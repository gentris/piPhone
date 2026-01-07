//
//  AppsView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct ApptItem: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

struct AppSection: Identifiable {
    var id = UUID()
    var title: String
    var items: [ApptItem]
}

struct AppsView: View {
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newIcon = "app.fill"
    
    private func addNewApp() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newItem = ApptItem(
            title: trimmed,
            icon: newIcon,
        )

        sections[0].items.append(newItem)

        // reset form
        newTitle = ""
        newIcon = "app.fill"
        showAddSheet = false
    }
    
    @State private var sections: [AppSection] = [
        .init(title: "Build-in Apps", items: [
            .init(title: "UI change", icon: "photo"),
            .init(title: "Take a Break", icon: "timer"),
            .init(title: "Add new Task", icon: "map"),
            .init(title: "Add new Apple", icon: "phone"),
            .init(title: "Add new Ticket", icon: "map"),
            .init(title: "Should add a new Ticket", icon: "headphones"),
        ]),
        .init(title: "Custom Apps", items: [
            .init(title: "Change Theme", icon: "envelope"),
            .init(title: "Phone details", icon: "phone"),
            .init(title: "Take that dollar", icon: "dollarsign"),
            .init(title: "CreditCard", icon: "creditcard"),
        ])
    ]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    ForEach(sections) { section in
                        SectionHeader(title: section.title)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(section.items) { item in
                                NavigationLink {
                                    ShortcutDetailView(item: item)
                                } label: {
                                    AppIconCell(item: item)
                                        .contentShape(Rectangle())
                                        .contextMenu {
                                            Button { } label: { Label("Edit", systemImage: "pencil") }
                                            Button { } label: { Label("Duplicate", systemImage: "doc.on.doc") }
                                            Button(role: .destructive) { } label: { Label("Delete", systemImage: "trash") }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Apps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 10) {
                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddAppSheet(
                    title: $newTitle,
                    icon: $newIcon,
                    onAdd: { addNewApp() }
                )
            }
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.top, 6)
    }
}

struct ShortcutCard: View {
    let item: ApptItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator).opacity(0.5), lineWidth: 0)
                )

            Image(systemName: item.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color(.label))
            
        }
        .frame(width: 72, height: 72)
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 0,
            x: 0,
            y: 2
        )
    }
}


struct AppIconCell: View {
    let item: ApptItem

    var body: some View {
        VStack(spacing: 8) {
            ShortcutCard(item: item)

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



struct ShortcutDetailView: View {
    let item: ApptItem

    var body: some View {
        VStack(spacing: 16) {
            ShortcutCard(item: item)
                .padding()

            Text("Detail screen for: \(item.title)")
                .font(.title3)

            Spacer()
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddAppSheet: View {
    @Binding var title: String
    @Binding var icon: String
    
    let onAdd: () -> Void

    private let iconOptions: [String] = [
        "app.fill", "sparkles", "star.fill", "bolt.fill", "flame.fill",
        "timer", "bell.fill", "heart.fill", "bookmark.fill", "paperplane.fill",
        "camera.fill", "photo.fill", "music.note", "headphones", "gamecontroller.fill",
        "message.fill", "phone.fill", "envelope.fill", "map.fill", "location.fill",
        "cart.fill", "creditcard.fill", "dollarsign.circle.fill", "chart.bar.fill",
        "cloud.fill", "wifi", "lock.fill", "key.fill", "person.fill", "person.2.fill"
    ]

    // 5 columns icon grid
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationStack {
            Form {
                Section("App Info") {
                    TextField("App name", text: $title)
                }

                Section("Icon") {
                    // shows currently selected icon
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title2)
                        Text(icon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // grid picker
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(iconOptions, id: \.self) { name in
                            Button {
                                icon = name
                            } label: {
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
