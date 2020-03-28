//
//  VerticalArrowKeyView.swift
//  piPhone
//
//  Created by Gentris Leci on 3/26/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import UIKit

class VerticalArrowKeyView: KeyView {
    private var _height: CGFloat = 17.0
    override var height: CGFloat {
        get {
            return _height
        }
        set {}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String?) {
        super.init(title: title, height: _height)
    }
}
