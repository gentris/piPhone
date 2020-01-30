//
//  KeyboardView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/28/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import WebKit

class KeyboardView: KBWebViewBase {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.load()
    }
    
    override var inputAccessoryView: UIView? {
        return nil
    }
    
    private func load() {
        let url = Bundle.main.url(forResource: "kb", withExtension: "html")!
        loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
