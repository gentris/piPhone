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

class TermView: WKWebView, WKNavigationDelegate {
    var ready: Bool = false
    
    override var canResignFirstResponder: Bool { return false }
    override func becomeFirstResponder() -> Bool { return false }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.load()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func load() {
        self.configuration.userContentController.addUserScript(initScript())
        
        let url = Bundle.main.url(forResource: "term", withExtension: "html")!
        self.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    func initScript() -> WKUserScript {
        let script = NSMutableArray()
        script.add("function applyUserSettings() {")
        script.add("term_set('cursor-blink', true);")
        script.add("term_setFontSize(12);")
        script.add("};")
        script.add("term_init();")
        script.add("term_write(\"\\u001b]1337;BlinkPrompt=eyJzZWN1cmUiOmZhbHNlLCJzaGVsbCI6dHJ1ZSwicHJvbXB0IjoiYmxpbms+ICJ9\\u0007\");")
        return WKUserScript(source: script.componentsJoined(by: "\n"), injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
    }
    
    func write(_ data: String) {
        var jsonData: Data?
        
        do {
            try jsonData = JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
        } catch {
            return
        }
        
        var result = Data(capacity: (jsonData?.count ?? 0) + 11 + 2)
        result.append("term_write(", count: 11)
        if let jsonData = jsonData {
            result.append(jsonData)
        }
        result.append(");", count: 2)
        
        let output: String = String(data: result, encoding: .utf8)!
        self.evaluateJavaScript(output, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ready = true
        
    }
}
