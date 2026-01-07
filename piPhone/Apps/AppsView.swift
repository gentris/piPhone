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

struct AppsView: View {
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newIcon = ""
    @State private var searchText = ""

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
                                ShortcutDetailView(item: item)
                            } label: {
                                VStack(spacing: 8) {
                                    AppCard(item: item)
                                        .contentShape(Rectangle())
                                        .contextMenu {
                                            Button { } label: { Label("Edit", systemImage: "pencil") }
                                            Button { } label: { Label("Duplicate", systemImage: "doc.on.doc") }
                                            Button(role: .destructive) { } label: { Label("Delete", systemImage: "trash") }
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
            .sheet(isPresented: $showAddSheet) {
                AddAppSheet(title: $newTitle, icon: $newIcon, onAdd: { addNewApp() })
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



struct ShortcutDetailView: View {
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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationStack {
            Form {
                Section("App Info") {
                    TextField("App name", text: $title)
                }

                Section("Icon") {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title2)
                        Text(icon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

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



#Preview {
    ContentView()
}
