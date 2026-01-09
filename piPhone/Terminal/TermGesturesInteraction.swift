//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
// This file contains parts of from an original project called Blink.
// If you want to know more about Blink, see <http://www.github.com/blinksh/blink>.
//
// Modified by Gentris Leci on 1/12/20.
//
// Copyright © 2019 Gentris Leci.
//
// This file is part of piPhone
//
// piPhone is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// piPhone is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with piPhone.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import WebKit

class TermGesturesInteraction: NSObject, UIInteraction {
    private var terminalWebView: TerminalWebView?
    private var keyboardInputWebView: KeyboardInputWebView?
    private let scrollView = UIScrollViewWithoutHitTest()
    private let oneTapRecognizer = UITapGestureRecognizer()
    private let pinchRecognizer = UIPinchGestureRecognizer()
    private var recognizers:[UIGestureRecognizer] {
        return [scrollView.panGestureRecognizer, oneTapRecognizer, pinchRecognizer]
    }
    private let jsScollerPath:String
    var focused: Bool = true
    var view: UIView?
    
    init(jsScrollerPath: String, keyboardInputWebView: KeyboardInputWebView) {
        self.jsScollerPath = jsScrollerPath
        super.init()
        self.keyboardInputWebView = keyboardInputWebView
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        
        oneTapRecognizer.numberOfTapsRequired = 1
        oneTapRecognizer.numberOfTouchesRequired = 1
        oneTapRecognizer.delegate = self
        oneTapRecognizer.addTarget(self, action: #selector(self.handleOneTap(_:)))
        
        pinchRecognizer.delegate = self
        pinchRecognizer.addTarget(self, action: #selector(self.handlePinch(_:)))
    }
    
    func willMove(to view: UIView?) {
        if let terminalWebView = view as? TerminalWebView {
            terminalWebView.scrollView.delaysContentTouches = false;
            terminalWebView.scrollView.canCancelContentTouches = false;
            terminalWebView.scrollView.isScrollEnabled = false;
            terminalWebView.scrollView.panGestureRecognizer.isEnabled = false;
          
          
            scrollView.frame = terminalWebView.bounds
            terminalWebView.addSubview(scrollView)
            terminalWebView.configuration.userContentController.add(self, name: "wkScroller")
            
            for recognizer in recognizers {
                terminalWebView.addGestureRecognizer(recognizer)
            }
            
            self.terminalWebView = terminalWebView
        } else {
            scrollView.removeFromSuperview()
            terminalWebView?.configuration.userContentController.removeScriptMessageHandler(forName: "wkScroller")
          
            for recognizer in recognizers {
                terminalWebView?.addGestureRecognizer(recognizer)
            }
          
            terminalWebView = nil
        }
    }
    
    func didMove(to view: UIView?) {
        self.view = view
    }
    
    @objc func handleOneTap(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
            case .recognized:
                keyboardInputWebView?.becomeFirstResponder()
            default: break
        }
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
      if  recognizer.state == .possible {
        return
      }
      
      let dScale = 1.0 - recognizer.scale;
      if abs(dScale) > 0.06 {

        recognizer.view?.superview?.dropSuperViewTouches()
        scrollView.panGestureRecognizer.dropTouches()
        
          terminalWebView?.scaleWithPinch(recognizer)
      }
    }
}

extension TermGesturesInteraction: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension TermGesturesInteraction: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        terminalWebView?.evaluateJavaScript("\(jsScollerPath).reportScroll(\(offset.x), \(offset.y));", completionHandler: nil)
    }
}

extension TermGesturesInteraction: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      guard
        let msg = message.body as? [String: Any],
        let op = msg["op"] as? String
      else {
        return
      }
      
      switch op {
      case "resize":
        let contentSize = NSCoder.cgSize(for: msg["contentSize"] as? String ?? "")
        scrollView.contentSize = contentSize
        let offset = CGPoint(x: 0, y: max(contentSize.height - scrollView.bounds.height, 0));
        scrollView.contentOffset = offset
        
      case "scrollTo":
        let animated = msg["animated"] as? Bool == true
        let x: CGFloat = msg["x"] as? CGFloat ?? 0
        let y: CGFloat = msg["y"] as? CGFloat ?? 0
        let offset = CGPoint(x: x, y: y)
        if (offset == scrollView.contentOffset) {
          return
        }
        // TODO: debounce?
        scrollView.setContentOffset(offset, animated: animated)
      default: break
      }
    }
}

class UIScrollViewWithoutHitTest: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let scrollBarWidth: CGFloat = 24
        if let result = super.hitTest(point, with: event),
            result !== self || point.x > self.bounds.size.width - scrollBarWidth {
            return result
        }
        return nil
    }
}
