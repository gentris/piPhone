//
//  KeyboardAccessoryViewController.swift
//  piPhone
//
//  Created by Gentris Leci on 3/20/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import UIKit

class KeyboardAccessoryViewController: UIInputViewController {
    var width: CGFloat = UIScreen.main.bounds.width
    var height: CGFloat = 45.0
    var keys: [Key] = [Key]()
    var leftKeyViews: [KeyView] = [KeyView]()
    var rightKeyViews: [KeyView] = [KeyView]()
    var keyboardAccessoryView: KeyboardAccessoryView?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.view.frame.size.width = UIScreen.main.bounds.width
        self.view.setNeedsLayout()
    }
    
    override func loadView() {
        super.loadView()
        self.view = KeyboardAccessoryView(width: self.width, height: self.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeys()
        self.addActionListeners()
    }
    
    private func addKeys() {
        self.addKey(data: Key(name: "esc", value: "esc", orientation: .left), action: self.handleControlKey(_:))
        self.addKey(data: Key(name: "ctrl", value: "ctrl", orientation: .left), action: self.handleControlKey(_:))
        self.addKey(data: Key(name: "tab", value: "tab", orientation: .left), action: self.handleTabKey(_:))
        
        self.addKey(data: Key(name: "▶", value: "▶", orientation: .right), action: nil)
        self.addVerticalArrowKeys(topKey: Key(name: "▲", value: "▲", orientation: .right), bottomKey: Key(name: "▼", value: "▼", orientation: .right))
        self.addKey(data: Key(name: "◀", value: "◀", orientation: .right), action: nil)
    }
    
    private func addKey(data key: Key, action: ((KeyView?) -> Void)?) {
        let keyView = KeyView(title: key.name)
        self.addKeyViewToSuperview(keyView: keyView, orientation: key.orientation)
        self.addKeyViewConstraints(for: keyView, orientation: key.orientation)
    }
    
    private func addVerticalArrowKeys(topKey: Key, bottomKey: Key) {
        if topKey.orientation != bottomKey.orientation {
            return
        }
        
        let orientation = topKey.orientation
        let topKeyView = VerticalArrowKeyView(title: topKey.name)
        let bottomKeyView = VerticalArrowKeyView(title: bottomKey.name)
        self.addKeyViewToSuperview(keyView: topKeyView, orientation: orientation)
        self.addKeyViewToSuperview(keyView: bottomKeyView, orientation: orientation)
        self.addVerticalArrowKeyViewsConstraints(for: topKeyView, and: bottomKeyView, orientation: orientation)
    }
    
    private func addKeyViewToSuperview(keyView: KeyView, orientation: Orientation) {
        if orientation == .left {
            self.leftKeyViews.append(keyView)
        } else {
            self.rightKeyViews.append(keyView)
        }
        
        self.view.addSubview(keyView)
    }
    
    private func addKeyViewConstraints(for keyView: KeyView, orientation: Orientation) {
        keyView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            keyView.widthAnchor.constraint(equalToConstant: keyView.width),
            keyView.heightAnchor.constraint(equalToConstant: keyView.height),
            keyView.bottomAnchor.constraint(equalTo: keyView.superview!.bottomAnchor, constant: -1.05)
        ]
        
        if orientation == .left {
            if keyView == self.leftKeyViews.first {
                constraints.append(keyView.leadingAnchor.constraint(equalTo: keyView.superview!.leadingAnchor, constant: 5.0))
            } else {
                if let index = self.leftKeyViews.firstIndex(of: keyView) {
                    constraints.append(keyView.leadingAnchor.constraint(equalTo: self.leftKeyViews[index - 1].trailingAnchor, constant: 5.0))
                }
            }
        } else {
            if keyView == self.rightKeyViews.first {
                constraints.append(keyView.trailingAnchor.constraint(equalTo: keyView.superview!.trailingAnchor, constant: -5.0))
            } else {
                if let index = self.rightKeyViews.firstIndex(of: keyView) {
                    constraints.append(keyView.trailingAnchor.constraint(equalTo: self.rightKeyViews[index - 1].leadingAnchor, constant: -5.0))
                }
            }
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addVerticalArrowKeyViewsConstraints(for topKeyView: VerticalArrowKeyView, and bottomKeyView: VerticalArrowKeyView, orientation: Orientation) {
        topKeyView.translatesAutoresizingMaskIntoConstraints = false
        bottomKeyView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            topKeyView.widthAnchor.constraint(equalToConstant: topKeyView.width),
            topKeyView.heightAnchor.constraint(equalToConstant: topKeyView.height),
            topKeyView.bottomAnchor.constraint(equalTo: bottomKeyView.topAnchor, constant: -1),
            bottomKeyView.widthAnchor.constraint(equalToConstant: bottomKeyView.width),
            bottomKeyView.heightAnchor.constraint(equalToConstant: bottomKeyView.height),
            bottomKeyView.bottomAnchor.constraint(equalTo: bottomKeyView.superview!.bottomAnchor, constant: -1.05)
        ]
        
        if orientation == .left {
            if topKeyView == self.leftKeyViews.first {
                constraints = constraints + [
                    topKeyView.leadingAnchor.constraint(equalTo: topKeyView.superview!.leadingAnchor, constant: 5.0),
                    bottomKeyView.leadingAnchor.constraint(equalTo: bottomKeyView.superview!.leadingAnchor, constant: 5.0)
                ]
            } else {
                if let index = self.leftKeyViews.firstIndex(of: topKeyView) {
                    constraints = constraints + [
                        topKeyView.leadingAnchor.constraint(equalTo: self.leftKeyViews[index - 1].trailingAnchor, constant: 5.0),
                        bottomKeyView.leadingAnchor.constraint(equalTo: self.leftKeyViews[index - 1].trailingAnchor, constant: 5.0)
                    ]
                }
            }
        } else {
            if topKeyView == self.rightKeyViews.first {
                constraints = constraints + [
                    topKeyView.trailingAnchor.constraint(equalTo: topKeyView.superview!.trailingAnchor, constant: -5.0),
                    bottomKeyView.trailingAnchor.constraint(equalTo: bottomKeyView.superview!.trailingAnchor, constant: -5.0),
                ]
            } else {
                if let index = self.rightKeyViews.firstIndex(of: topKeyView) {
                    constraints = constraints + [
                        topKeyView.trailingAnchor.constraint(equalTo: self.rightKeyViews[index - 1].leadingAnchor, constant: -5.0),
                        bottomKeyView.trailingAnchor.constraint(equalTo: self.rightKeyViews[index - 1].leadingAnchor, constant: -5.0),
                    ]
                }
            }
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addActionListeners() {
        let keyViews = self.leftKeyViews + self.rightKeyViews
        for keyView in keyViews {
            if keyView.titleLabel?.text == "ctrl" {
                keyView.addTarget(self, action: #selector(self.handleControlKey(_:)), for: .touchUpInside)
            } else if keyView.titleLabel?.text == "tab" {
                keyView.addTarget(self, action: #selector(self.handleTabKey(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func handleControlKey(_ sender: KeyView?) {
        print("Control key clicked...")
    }
    
    @objc func handleTabKey(_ sender: KeyView?) {
        print("Tab key clicked...")
    }
}
