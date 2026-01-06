//
//  ContentView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DeviceView()
                .tabItem {
                    Label("Device", systemImage: "antenna.radiowaves.left.and.right")
                }

            AppsView()
                .tabItem {
                    Label("Apps", systemImage: "square.grid.2x2")
                }

            TerminalView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal")
                }
        }
    }
}

#Preview {
    ContentView()
}
