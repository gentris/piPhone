//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
// This file contains parts of from an original project called Blink.
// If you want to know more about Blink, see <http://www.github.com/blinksh/blink>.
//
// Modified by Gentris Leci on 1/28/20.
// Copyright © 2019 Gentris Leci.
//
// This file is part of piPhone
//
// piPhone is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// piPhone is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with piPhone.  If not, see <https://www.gnu.org/licenses/>.
//

import WebKit

class KeyboardInputWebView: KBWebViewBase {
    var keyboardAccessoryViewController: KeyboardAccessoryViewController =
        KeyboardAccessoryViewController()
    var controlKeyIsActive: Bool = false

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        frame: CGRect, configuration: WKWebViewConfiguration,
        specialKeysDelegate: SpecialKeysDelegate
    ) {
        super.init(frame: frame, configuration: configuration)
        self.keyboardAccessoryViewController.keysDelegate = specialKeysDelegate
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.load()
    }

    override var inputAccessoryViewController: UIInputViewController? {
        return self.keyboardAccessoryViewController
    }

    override var inputAccessoryView: UIView? {
        return nil
    }

    private func load() {
        let url = Bundle.main.url(forResource: "kb", withExtension: "html")!
        loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    func reportControlKeyPressed() {
        self.controlKeyIsActive = !self.controlKeyIsActive

        var payload: String
        if self.controlKeyIsActive {
            payload = "_onKB(\"toolbar-mods\", 262144);"
        } else {
            payload = "_onKB(\"toolbar-mods\", 0);"
        }

        self.evaluateJavaScript(payload, completionHandler: nil)
    }

    func reportControlKeyReleased() {
        self.controlKeyIsActive = false
        let payload = "_onKB(\"toolbar-mods\", 0);"
        self.evaluateJavaScript(payload, completionHandler: nil)
    }
}
