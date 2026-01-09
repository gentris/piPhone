//
// Created by Gentris Leci on 1/29/20.
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

import Foundation
import CoreBluetooth

class Peripheral {
    var cbPeripheral: CBPeripheral
    var service: CBService?
    var screenCharacteristic: CBCharacteristic?
    var commandCharacteristic: CBCharacteristic?
    
    init(cbPeripheral: CBPeripheral) {
        self.cbPeripheral = cbPeripheral
    }
    
    func write(data input: String, characteristic: CBCharacteristic?) {
        let data = input.data(using: String.Encoding.utf8)!
        
        if let characteristic = characteristic {
            cbPeripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
