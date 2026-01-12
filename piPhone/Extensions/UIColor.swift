//
//  TomorrowColors.swift
//  piPhone
//
//  Created by Eris Leci on 1/11/26.
//

import UIKit

extension UIColor {
    struct RunestoneColors {
        var background: UIColor { .systemBackground }

        var selection: UIColor {
            UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
        }

        var currentLine: UIColor {
            UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        }
        
        var foreground: UIColor { .label }

        var comment: UIColor { .secondaryLabel }

        var red: UIColor {
            UIColor(red: 196 / 255, green: 74 / 255, blue: 62 / 255, alpha: 1)
        }

        var orange: UIColor {
            UIColor(red: 236 / 255, green: 157 / 255, blue: 68 / 255, alpha: 1)
        }

        var yellow: UIColor {
            UIColor(red: 232 / 255, green: 196 / 255, blue: 66 / 255, alpha: 1)
        }

        var green: UIColor {
            UIColor(red: 136 / 255, green: 154 / 255, blue: 46 / 255, alpha: 1)
        }

        var aqua: UIColor {
            UIColor(red: 100 / 255, green: 166 / 255, blue: 173 / 255, alpha: 1)
        }

        var blue: UIColor {
            UIColor(red: 94 / 255, green: 133 / 255, blue: 184 / 255, alpha: 1)
        }

        var purple: UIColor {
            UIColor(red: 149 / 255, green: 115 / 255, blue: 179 / 255, alpha: 1)
        }

        fileprivate init() {}
    }

    static let runestone = RunestoneColors()
}

