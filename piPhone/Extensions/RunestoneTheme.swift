//
//  RunestoneTheme.swift
//  piPhone
//
//  Created by Eris Leci on 1/11/26.
//

import Runestone
import UIKit

final class RunestoneTheme: Theme {
    let font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    let textColor: UIColor = .tomorrow.foreground

    let gutterBackgroundColor: UIColor = .clear
    let gutterHairlineColor: UIColor = .clear

    let lineNumberColor: UIColor = .tomorrow.comment
    let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)

    let selectedLineBackgroundColor: UIColor = .tomorrow.foreground
    let selectedLinesLineNumberColor: UIColor = .tomorrow.foreground
    let selectedLinesGutterBackgroundColor: UIColor = .tomorrow.background

    let invisibleCharactersColor: UIColor = .tomorrow.comment

    let pageGuideHairlineColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.1)
    let pageGuideBackgroundColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.2)

    let markedTextBackgroundColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.2)

    func textColor(for highlightName: String) -> UIColor? {
        switch highlightName {
        case "comment": return .tomorrow.comment
        case "string": return .tomorrow.green
        case "number": return .tomorrow.orange
        case "keyword": return .tomorrow.purple
        case "function": return .tomorrow.blue
        case "type": return .tomorrow.yellow
        case "constant", "boolean": return .tomorrow.orange
        default: return nil
        }
    }
}
