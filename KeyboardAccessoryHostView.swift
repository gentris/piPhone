//
//  KeyboardAccessoryHostView.swift
//  piPhone
//
//  Created by Gentris Leci on 12/30/25.
//  Copyright © 2025 Gentris Leci. All rights reserved.
//

import UIKit
import SwiftUI

final class KeyboardAccessoryHostView: UIInputView {
    private let hosting: UIHostingController<KeyboardAccessoryView>

    init(height: CGFloat = 45, onTap: @escaping (String) -> Void) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)

        hosting = UIHostingController(
            rootView: KeyboardAccessoryView(onTap: onTap)
        )

        super.init(frame: frame, inputViewStyle: .keyboard)

        backgroundColor = .clear
        hosting.view.backgroundColor = .clear

        addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
