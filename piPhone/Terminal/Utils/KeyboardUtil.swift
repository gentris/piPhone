//
//  KeyboardUtil.swift
//  piPhone
//
//  Created by Gentris Leci on 3/18/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import Foundation

class KeyboardUtil {
    static func generateControlAscii(character char: String) -> UInt8 {
        if let ascii = Character(char).asciiValue {
            return ascii - 64
        }
        
        return 0
    }
}
