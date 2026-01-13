//
//  DeviceView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import RealityKit
import SwiftUI

struct DeviceView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                DeviceRealityView()

                DeviceSettingsView()
            }
            .padding()
            .navigationTitle("Device")
        }
    }
}

struct DeviceRealityView: View {
    var body: some View {
        //        RealityView { content in
        //            if let model = try? await ModelEntity(named: "piPhone-20260104-final") {
        //                model.transform.scale *= 20.0
        //                model.generateCollisionShapes(recursive: true)
        //
        //                content.add(model)
        //            }
        //            Task {
        //                // Asynchronously perform any additional work to configure
        //                // the content after the system renders the view.
        //            }
        //        }
        EmptyView()
    }
}

struct DeviceSettingsView: View {
    private enum DeviceSettings: CaseIterable, Identifiable {
        case wifi, bluetooth, battery, storage, about

        var id: Self { self }

        var title: String {
            switch self {
            case .battery: return "Battery"
            case .wifi: return "Wi-Fi"
            case .bluetooth: return "Bluetooth"
            case .storage: return "Storage"
            case .about: return "About"
            }
        }

        var iconName: String {
            switch self {
            case .battery: return "battery.25"
            case .wifi: return "wifi"
            case .bluetooth: return "bluetooth.materialdesign"  // your custom asset name
            case .storage: return "externaldrive"
            case .about: return "info.circle"
            }
        }

        /// Trailing value (same line). nil = no trailing text
        var trailingValue: String? {
            switch self {
            case .battery: return "25%"
            case .wifi: return "Off"
            case .bluetooth: return "On"
            case .storage: return ""
            case .about: return nil
            }
        }

        var iconFontWeight: Font.Weight {
            self == .bluetooth ? .bold : .regular
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(DeviceSettings.allCases) { row in
                    NavigationLink {
                        PlaceholderDestination(title: row.title)
                    } label: {
                        HStack(spacing: 12) {
                            iconView(for: row)
                                .foregroundStyle(.blue)

                            Text(row.title)

                            Spacer()

                            if let value = row.trailingValue {
                                Text(value)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Device")
        }
    }

    @ViewBuilder
    private func iconView(for setting: DeviceSettings) -> some View {
        // If it's an SF Symbol, use Image(systemName:).
        // Otherwise (your bluetooth asset), fall back to Image(name:).
        if UIImage(systemName: setting.iconName) != nil {
            Image(systemName: setting.iconName)
                .font(.system(size: 17, weight: setting.iconFontWeight))
                .frame(width: 22)
        } else {
            Image(setting.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .frame(width: 22)
        }
    }
}

private struct PlaceholderDestination: View {
    let title: String
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Text(title)
                .foregroundStyle(.secondary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
