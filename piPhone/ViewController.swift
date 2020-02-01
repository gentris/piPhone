//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
// This file contains parts of from an original project called Blink.
// If you want to know more about Blink, see <http://www.github.com/blinksh/blink>.
//
// Modified by Gentris Leci on 12/17/19.
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
import CoreBluetooth

class ViewController: UIViewController, WKScriptMessageHandler, PiPhoneDelegate {
    var peripheral: Peripheral?
    private var termView: TermView!
    private var keyboardView: KeyboardView!
    private var coverView: UIView!
    private let termViewScriptName = "interOp"
    private let keyboardViewScriptName = "_kb"
    private var bluetoothManager: BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSubViews()
    }
    
    private func loadSubViews() {
        let configuration = WKWebViewConfiguration()
        configuration.selectionGranularity = .character
        configuration.userContentController.add(self, name: termViewScriptName)
        configuration.userContentController.add(self, name: keyboardViewScriptName)
        
        termView = TermView(frame: UIScreen.main.bounds, configuration: configuration)
        keyboardView = KeyboardView(frame: .zero, configuration: configuration)
        coverView = UIView(frame: UIScreen.main.bounds)
        
        coverView.backgroundColor = .black
        
        let interaction = TermGesturesInteraction(jsScrollerPath: "t.scrollPort_.scroller_", keyboardView: keyboardView)
        termView.addInteraction(interaction)
        
        view.addSubview(termView)
        view.addSubview(keyboardView)
        view.addSubview(coverView)
    }
    
    // Delegate functions
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Message.Name: ", message.name)
            if message.name == self.termViewScriptName {
                let sentData: NSDictionary = message.body as! NSDictionary
                let operation:String = sentData["op"] as! String

                if operation == "terminalReady" {
                    self.terminalReady()
                }
            } else if message.name == self.keyboardViewScriptName {
                let body: NSDictionary = message.body as! NSDictionary
                guard let op: String = body["op"] as? String else {
                    return
                }
                
                if (op == "out") {
                    let data: String = body["data"] as! String
                    peripheral?.write(data: data)
                    print("kbData: ", data)
                }
            }
    }
    
    func didConnect() {}
    func didDisconnect() {}
    func didFailToConnect() {}

    func didExecuteCommand(response: Data) {
        let data:String = String(data: response, encoding: String.Encoding.utf8)!
        termView.write(data)
    }
    
    @objc public func scaleWithPinch(_ pinch: UIPinchGestureRecognizer) {
        print("ScaleWithPinch...")
    }
    
    func terminalReady() {
        UIView.transition(from: coverView, to: termView, duration: 0.3, options: .transitionCrossDissolve) { finished in
            self.coverView.removeFromSuperview()
            self.keyboardView.readyForInput = true
            self.keyboardView.becomeFirstResponder()
            
            self.bluetoothManager = BluetoothManager()
            self.bluetoothManager.piPhoneDelegate = self
        }
    }
}
