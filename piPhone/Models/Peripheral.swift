//
//  Peripheral.swift
//  piPhone
//
//  Created by Gentris Leci on 1/29/20.
//  Copyright © 2020 Gentris Leci. All rights reserved.
//

import Foundation
import CoreBluetooth

class Peripheral {
    var cbPeripheral: CBPeripheral?
    var service: CBService?
    var characteristic: CBCharacteristic?
    
    func write(data input: String) {
        let data = input.data(using: String.Encoding.utf8)!
        
        if let characteristic = self.characteristic {
            if let peripheral = cbPeripheral {
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
}

//class Peripheral: CBPeripheral {
//    var device: CBPeripheral?
//    var service: CBService?
//    var characteristic: CBCharacteristic?
//
//    func write(data input: String) {
//        let data = input.data(using: String.Encoding.utf8)!
//
//        if let characteristic = self.characteristic {
//            device?.writeValue(data, for: characteristic, type: .withResponse)
//        }
//    }
//}
