//
//  KeyView.swift
//  piPhone
//
//  Created by Gentris Leci on 3/18/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import UIKit

class KeyView: UIButton {
    var width: CGFloat = 50.0
    var height: CGFloat = 35.0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String?) {
        self.init(title: title, height: nil)
    }
    
    init(title: String?, height: CGFloat?) {
        if let height = height {
            self.height = height
        }
        
        super.init(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        self.layer.cornerRadius = 5.3
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.45).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        self.layer.shadowPath = CGPath(roundedRect: CGRect(x: 0.4, y: frame.size.height - 8.95, width: self.frame.size.width - 0.6, height: 10.0), cornerWidth: 5.3, cornerHeight: 5.3, transform: nil)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.setTitle(title, for: .normal)
        self.setBackgroundColor()
        self.setForegroundColor()
    }
    
    private func setBackgroundColor() {
        let color: UIColor?
        
        if #available(iOS 13, *) {
            color = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(displayP3Red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0)
                } else {
                    return UIColor.white
                }
            }
        } else {
            color = UIColor.white
        }
        
        self.backgroundColor = color
    }
    
    private func setForegroundColor() {
        let color: UIColor?
        
        if #available(iOS 13, *) {
            color = UIColor {(traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor.white
                } else {
                    return UIColor.black
                }
            }
        } else {
            color = UIColor.white
        }
        
        self.setTitleColor(color, for: .normal)
    }
}
