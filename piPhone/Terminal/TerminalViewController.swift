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
import Combine

class TerminalViewController: UIViewController {
    var peripheral: Peripheral?
    
    private let terminalWebViewScriptName = "interOp"
    private let keyboardInputWebViewScriptName = "_kb"
    
    private var terminalWebView: TerminalWebView!
    private var keyboardInputWebView: KeyboardInputWebView!
    
    private var bluetoothManager: BluetoothManager
    private var cancellables = Set<AnyCancellable>()
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSubViews()
        self.subscribeToKeyboardEvents()
        self.subscribeToBluetoothEvents()
    }
    
    private func loadSubViews() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: terminalWebViewScriptName)
        configuration.userContentController.add(self, name: keyboardInputWebViewScriptName)
        
        self.keyboardInputWebView = KeyboardInputWebView(frame: .zero, configuration: configuration, specialKeysDelegate: self)
        
        self.terminalWebView = TerminalWebView(frame: self.getTerminalWebViewFrame(), configuration: configuration)
        self.terminalWebView.addInteraction(TermGesturesInteraction(jsScrollerPath: "t.scrollPort_.scroller_", keyboardInputWebView: self.keyboardInputWebView))
        self.terminalWebView.isOpaque = false
        self.terminalWebView.backgroundColor = .black
        self.terminalWebView.scrollView.isOpaque = false
        self.terminalWebView.scrollView.backgroundColor = .black
        
        self.view.addSubview(terminalWebView)
        self.view.addSubview(keyboardInputWebView)
    }
    
    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func subscribeToBluetoothEvents() {
        bluetoothManager.$bluetoothState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                var stateString = ""
                if (state == .off) {
                    stateString = "OFF"
                } else if (state == .on) {
                    stateString = "ON"
                } else {
                    stateString = "N/A"
                }
                
                let data = "[piPhone] Bluetooth state: \(stateString).\r\n"
                self.terminalWebView.write(data)
            }
            .store(in: &cancellables)
        
        bluetoothManager.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                if state == .connected {
                    self.terminalWebView.write("[piPhone] Connected to peripheral.\r\n")
                } else if state == .disconnected {
                    self.terminalWebView.write("[piPhone] Disconnected from peripheral.\r\n")
                } else if state == .failedToConnect {
                    self.terminalWebView.write("[piPhone] Failed to connect to peripheral.\r\n")
                }
            }
            .store(in: &cancellables)
        
        bluetoothManager.$receivedData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bytes in
                guard let self else { return }
                
                if let data:String = String(data: bytes, encoding: String.Encoding.utf8) {
                    self.terminalWebView.write(data)
                }
            }
            .store(in: &cancellables)
        
        bluetoothManager.$peripheral
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peripheral in
                guard let self else { return }
                
                self.peripheral = peripheral
            }
            .store(in: &cancellables)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.terminalWebView.frame = self.getTerminalWebViewFrame(keyboardFrame: keyboardFrame)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.terminalWebView.frame = self.getTerminalWebViewFrame(keyboardFrame: nil)
    }
    
    func getTerminalWebViewFrame(keyboardFrame: CGRect? = nil) -> CGRect {
        var terminalWebViewInsets = view.window?.safeAreaInsets ?? .zero
        
        if let keyboardHeight = keyboardFrame?.height {
            terminalWebViewInsets.bottom = max(terminalWebViewInsets.bottom, keyboardHeight)
        }
        return UIScreen.main.bounds.inset(by: terminalWebViewInsets)
    }
    
}

extension TerminalViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Message.Name: ", message.name)
        if message.name == self.terminalWebViewScriptName {
            let payload: NSDictionary = message.body as! NSDictionary
            let operation:String = payload["op"] as! String
            let data = payload["data"] as! NSDictionary
            
            if operation == "terminalReady" {
                let sizeData = data["size"] as! NSDictionary
                self.terminalReady(sizeData)
            } else if operation == "fontSizeChanged" {
                
            } else if operation == "sigwinch" {
                self.terminalWebView.cols = data["cols"] as! Int
                self.terminalWebView.rows = data["rows"] as! Int
                
                let data = "{\"cols\": \(self.terminalWebView.cols), \"rows\": \(self.terminalWebView.rows)}"
                self.peripheral?.write(data: data, characteristic: self.peripheral?.screenCharacteristic)
            }
        } else if message.name == self.keyboardInputWebViewScriptName {
            let body: NSDictionary = message.body as! NSDictionary
            guard let op: String = body["op"] as? String else {
                return
            }
            
            if (op == "out") {
                let data: String = body["data"] as! String
                self.peripheral?.write(data: data, characteristic: self.peripheral?.commandCharacteristic);
                
                if self.keyboardInputWebView.controlKeyIsActive {
                    self.keyboardInputWebView.reportControlKeyReleased()
                }
            }
        }
    }
    
    private func terminalReady(_ data: NSDictionary) {
        self.keyboardInputWebView.readyForInput = true
        self.keyboardInputWebView.becomeFirstResponder()
        
        self.terminalWebView.cols = data["cols"] as! Int
        self.terminalWebView.rows = data["rows"] as! Int
    }
}

extension TerminalViewController: SpecialKeysDelegate {
    func didClickSpecialKey(key: Key) {
        self.peripheral?.write(data: key.ansi, characteristic: self.peripheral?.commandCharacteristic)
    }
    
    func didClickControlKey(key: Key) {
        self.keyboardInputWebView.reportControlKeyPressed()
    }
}
