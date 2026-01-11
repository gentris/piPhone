//
//  ASCIIControlCharacter.swift
//  piPhone
//
//  Created by Gentris Leci on 3/28/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import Foundation

enum KeyName {
    case esc
    case tab
    case ctrl
    case up
    case down
    case right
    case left
}

struct Key: Hashable {
    let name: KeyName
    let title: String
    let ansi: String
}

let keys: [KeyName: Key] = [
    .esc: Key(name: .esc, title: "esc", ansi: "\u{1B}"),
    .tab: Key(name: .tab, title: "tab", ansi: "\t"),
    .ctrl: Key(name: .ctrl, title: "ctrl", ansi: "CTRL"),
    .up: Key(name: .up, title: "▲", ansi: "\u{1B}[A"),
    .down: Key(name: .down, title: "▼", ansi: "\u{1B}[B"),
    .right: Key(name: .right, title: "▶", ansi: "\u{1B}[C"),
    .left: Key(name: .left, title: "◀", ansi: "\u{1B}[D"),
]
