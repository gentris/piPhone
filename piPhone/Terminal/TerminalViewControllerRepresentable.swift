//
//  TerminalViewControllerRepresentable.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI
import UIKit

struct TerminalViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TerminalViewController {
        TerminalViewController()
    }

    func updateUIViewController(_ uiViewController: TerminalViewController, context: Context) {
        // no-op
    }
}
