//
//  InputAccessoryView.swift
//  piPhone
//
//  Created by Gentris Leci on 3/17/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import UIKit

class KeyboardAccessoryView: UIInputView {
    init(width: CGFloat, height: CGFloat) {
        let size = CGSize(width: UIScreen.main.bounds.width, height: height)
        let frame = CGRect(origin: .zero, size: size)
        super.init(frame: frame, inputViewStyle: .keyboard)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
