//
// Created by Gentris Leci on 12/17/19.
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

protocol PiPhoneDelegate {
    var peripheral: Peripheral? { get set }
    func didUpdateBluetoothState(state: CBManagerState)
    func didConnect()
    func didDisconnect()
    func didFailToConnect()
    func didExecuteCommand(response: Data)
    func didUpdateNotificationStateFor(characteristic: CBCharacteristic)
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var piPhoneDelegate: PiPhoneDelegate?
    
    private var centralManager:CBCentralManager?
    private var pi:CBPeripheral?
    private var scanTimer:Timer?
    private var pauseTimer:Timer?
    
    private let serviceUUID = CBUUID(string: "50315dc8-bd51-4561-a9ec-eac52609b17a")
    private let screenCharacteristicUUID = CBUUID(string: "755ae080-461f-11ea-b77f-2e728ce88125")
    private let commandCharacteristicUUID = CBUUID(string: "e6b8f004-b286-4826-b6ca-cba2eb628c03")
    private let peripheralName = "pi"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    private func initScanTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startScanning), userInfo: nil, repeats: true)
    }
    
    private func initPauseTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(stopScanning), userInfo: nil, repeats: true)
    }
    
    @objc private func startScanning() {
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        if pauseTimer == nil {
            pauseTimer = initPauseTimer()
        }
    }
    
    @objc private func stopScanning() {
        centralManager?.stopScan()
        if scanTimer == nil {
            scanTimer = initScanTimer()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        piPhoneDelegate?.didUpdateBluetoothState(state: central.state)
        
        if central.state != CBManagerState.poweredOn {
            print("Bluetooth is not ready for communication.")
            return
        }
        
        print("Bluetooth is ON and ready for communication.")
        
        piPhoneDelegate?.didUpdateBluetoothState(state: central.state)
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            return;
        }
        
        if name == peripheralName {
            pi = peripheral
            pi?.delegate = self
            
            if var delegate = piPhoneDelegate {
                delegate.peripheral = Peripheral()
                delegate.peripheral?.cbPeripheral = peripheral
            }
            
            scanTimer?.invalidate()
            pauseTimer?.invalidate()

            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Couldn't connect to the peripheral.")
        
        if central.state != CBManagerState.poweredOn {
            print("Bluetooth is not ready for communication.")
            return
        }
        
        piPhoneDelegate?.didFailToConnect()
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected to the peripheral.")
        piPhoneDelegate?.didConnect()
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral got disconnected.")
        piPhoneDelegate?.didDisconnect()
        startScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error while discovering services: \(error.localizedDescription)")
            return;
        }
        
        guard let services = peripheral.services else {
            print("No services discovered.")
            return
        }
        
        print("Services discovered.")
        
        for service in services {
            print("Service with UUID: \(service.uuid)")
            peripheral.discoverCharacteristics([screenCharacteristicUUID, commandCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error while discovering characteristics: \(error.localizedDescription)")
            return;
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics discovered.")
            return
        }
        
        print("Characteristics discovered.")

        for characteristic in characteristics {
            print("Characteristic with UUID: \(characteristic.uuid)")
            pi?.setNotifyValue(true, for: characteristic)
            
            if characteristic.uuid == screenCharacteristicUUID {
                piPhoneDelegate?.peripheral?.screenCharacteristic = characteristic
            } else if characteristic.uuid == commandCharacteristicUUID {
                piPhoneDelegate?.peripheral?.commandCharacteristic = characteristic
            }
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        piPhoneDelegate?.didUpdateNotificationStateFor(characteristic: characteristic)
        if !characteristic.isNotifying {
            pi?.setNotifyValue(true, for: characteristic)
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error while updating the characteristic's value: \(error.localizedDescription)")
            return
        }
        
        if let value = characteristic.value {
            piPhoneDelegate?.didExecuteCommand(response: value)
        }
    }
}
