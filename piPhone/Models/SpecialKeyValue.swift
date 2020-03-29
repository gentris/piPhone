//
//  ASCIIControlCharacter.swift
//  piPhone
//
//  Created by Gentris Leci on 3/28/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import Foundation

enum SpecialKeyValue: String {
    case esc = "\u{1b}"
    case tab = "\u{9}"
    case ctrl = "CTRL"
    case up = "\u{1b}[A"
    case down = "\u{1b}[B"
    case right = "\u{1b}[C"
    case left = "\u{1b}[D"
}
