//
//  TermView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/28/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import WebKit

class TermView: WKWebView {
    override var canResignFirstResponder: Bool { return false }
    override func becomeFirstResponder() -> Bool { return false }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.load()
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
}
