//
//  AppsView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct ShortcutItem: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
    var colors: [Color]  // gradient colors
}

struct ShortcutSection: Identifiable {
    var id = UUID()
    var title: String
    var items: [ShortcutItem]
}

struct AppsView: View {
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newIcon = "app.fill"
    @State private var newColor: Color = .black
    
    
    private func addNewApp() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newItem = ShortcutItem(
            title: trimmed,
            icon: newIcon,
            colors: [newColor.opacity(0.6)]
        )

        sections[0].items.append(newItem)

        // reset form
        newTitle = ""
        newIcon = "app.fill"
        newColor = .black
        showAddSheet = false
    }
    
    @State private var sections: [ShortcutSection] = [
        .init(title: "Build-in Apps", items: [
            .init(title: "UI change", icon: "photo", colors: [.red]),
            .init(title: "Take a Break", icon: "timer", colors: [.blue]),
            .init(title: "Add new Task", icon: "map", colors: [.yellow]),
            .init(title: "Add new Apple", icon: "phone", colors: [.mint]),
            .init(title: "Add new Ticket", icon: "map", colors: [.yellow]),
            .init(title: "Should add a new Ticket", icon: "headphones", colors:[.black]),
        ]),
        .init(title: "Custom Apps", items: [
            .init(title: "Change Theme", icon: "envelope", colors: [.black]),
            .init(title: "Phone details", icon: "phone", colors: [.black]),
            .init(title: "Take that dollar", icon: "dollarsign", colors: [.black]),
            .init(title: "CreditCard", icon: "creditcard", colors: [.black]),
        ])
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
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
                    color: $newColor,
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
    let item: ShortcutItem

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
    let item: ShortcutItem

    var body: some View {
        VStack(spacing: 8) {
            ShortcutCard(item: item)

            Text(item.title)
                .font(.footnote)
                .foregroundStyle(Color(.label)) // ✅ dynamic
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 90)               // matches home screen feel
                .multilineTextAlignment(.center)
        }
    }
}



struct ShortcutDetailView: View {
    let item: ShortcutItem

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
    @Binding var color: Color

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
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(name == icon ? color.opacity(0.25) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(name == icon ? color : Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
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


#Preview { ContentView() }

