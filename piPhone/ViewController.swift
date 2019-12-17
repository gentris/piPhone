//
//  ViewController.swift
//  piPhone
//
//  Created by Gentris Leci on 12/17/19.
//  Copyright © 2019 Gentris Leci. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, PiPhoneDelegate {
    private var bluetoothManager: BluetoothManager!
    
    func didConnect() {
        print("Connected to Peripheral from PIPHONEDELEGATE...")
    }

    func didDisconnect() {
    }

    func didFailToConnect() {
    }

    func didExecuteCommand(response: String) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothManager = BluetoothManager()
        bluetoothManager.piPhoneDelegate = self
    }
}

