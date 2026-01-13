//
//  RunestoneView.swift
//  piPhone
//
//  Created by Eris Leci on 1/12/26.
//

import SwiftUI
import Runestone
import UIKit

import TreeSitterJavaRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterPythonRunestone

struct RunestoneView: UIViewRepresentable {
    @Binding var text: String
    var language: CodeLanguage

    func makeUIView(context: Context) -> TextView {
        let tv = TextView()
        tv.editorDelegate = context.coordinator

        tv.theme = RunestoneTheme()
        tv.backgroundColor = UIColor.clear

        tv.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        tv.showLineNumbers = true
        tv.lineHeightMultiplier = 1.2
        tv.kern = 0.3

        tv.characterPairs = defaultPairs
        tv.indentStrategy = .space(length: 4)
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.smartQuotesType = .no
        tv.smartDashesType = .no
        tv.smartInsertDeleteType = .no
        tv.spellCheckingType = .no

        tv.text = text
        applyLanguage(to: tv, language: language)

        return tv
    }

    func updateUIView(_ tv: TextView, context: Context) {
        if tv.text != text {
            tv.text = text
        }

        if context.coordinator.lastLanguage != language {
            context.coordinator.lastLanguage = language
            applyLanguage(to: tv, language: language)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, lastLanguage: language)
    }

    final class Coordinator: NSObject, TextViewDelegate {
        var text: Binding<String>
        var lastLanguage: CodeLanguage

        init(text: Binding<String>, lastLanguage: CodeLanguage) {
            self.text = text
            self.lastLanguage = lastLanguage
        }
    }

    private func applyLanguage(to tv: TextView, language: CodeLanguage) {
        switch language {
        case .plainText:
            tv.setLanguageMode(PlainTextLanguageMode())

        case .javaScript:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .javaScript))

        case .python:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .python))

        case .java:
            tv.setLanguageMode(TreeSitterLanguageMode(language: .java))
        }
    }
}

enum CodeLanguage: Equatable {
    case plainText
    case javaScript
    case python
    case java

    static func fromFilename(_ name: String) -> CodeLanguage {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let ext = (trimmed as NSString).pathExtension.lowercased()

        switch ext {
        case "js", "jsx", "mjs", "cjs":
            return .javaScript
        case "py":
            return .python
        case "java":
            return .java
        default:
            return .plainText
        }
    }
}

struct SimplePair: CharacterPair {
    let leading: String
    let trailing: String
}

private let defaultPairs: [CharacterPair] = [
    SimplePair(leading: "{", trailing: "}"),
    SimplePair(leading: "(", trailing: ")"),
    SimplePair(leading: "[", trailing: "]"),
    SimplePair(leading: "\"", trailing: "\""),
    SimplePair(leading: "'", trailing: "'"),
]
