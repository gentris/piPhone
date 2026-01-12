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
    let textColor: UIColor = .runestone.foreground

    let gutterBackgroundColor: UIColor = .clear
    let gutterHairlineColor: UIColor = .clear

    let lineNumberColor: UIColor = .runestone.comment
    let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)

    let selectedLineBackgroundColor: UIColor = .runestone.foreground
    let selectedLinesLineNumberColor: UIColor = .runestone.foreground
    let selectedLinesGutterBackgroundColor: UIColor = .runestone.background

    let invisibleCharactersColor: UIColor = .runestone.comment

    let pageGuideHairlineColor: UIColor = .runestone.foreground.withAlphaComponent(0.1)
    let pageGuideBackgroundColor: UIColor = .runestone.foreground.withAlphaComponent(0.2)

    let markedTextBackgroundColor: UIColor = .runestone.foreground.withAlphaComponent(0.2)

    func textColor(for highlightName: String) -> UIColor? {
        switch highlightName {
        case "comment": return .runestone.comment
        case "string": return .runestone.green
        case "number": return .runestone.orange
        case "keyword": return .runestone.purple
        case "function": return .runestone.blue
        case "type": return .runestone.yellow
        case "constant", "boolean": return .runestone.orange
        default: return nil
        }
    }
}
