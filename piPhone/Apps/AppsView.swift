//
//  AppsView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct AppsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Apps tab")
                    .font(.title2)

                Text("This is the Apps screen.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Apps")
        }
    }
}
