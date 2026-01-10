//
//  TerminalViewControllerRepresentable.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI
import UIKit

struct TerminalViewControllerRepresentable: UIViewControllerRepresentable {
    let bluetoothManager: BluetoothManager

    func makeUIViewController(context: Context) -> TerminalViewController {
        TerminalViewController(bluetoothManager: bluetoothManager)
    }

    func updateUIViewController(_ uiViewController: TerminalViewController, context: Context) {
        // no-op
    }
}
