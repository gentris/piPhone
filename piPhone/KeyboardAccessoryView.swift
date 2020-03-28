//
//  InputAccessoryView.swift
//  piPhone
//
//  Created by Gentris Leci on 3/17/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import UIKit

class InputAccessoryView: UIInputView {
    private var width: CGFloat = 0
    private let height: CGFloat = 45.0
    
    init(width: CGFloat) {
        self.width = width
        let size = CGSize(width: self.width, height: self.height)
        let frame = CGRect(origin: .zero, size: size)
        super.init(frame: frame, inputViewStyle: .keyboard)
        
        UIToolbar
        
        var initialPoint:CGFloat = 5;
        for i in 1...8 {
            let point = CGPoint(x: initialPoint, y: (self.frame.height - KeyView.height) / 2 + 3)
//            let some = KeyView(point: point)
//            some.addTarget(self, action: "buttonClicked", for: .touchDown)
            self.addSubview(KeyView(point: point))
            initialPoint = initialPoint + 7 + KeyView.width
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
