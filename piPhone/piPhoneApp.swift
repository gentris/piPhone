//
//  piPhoneApp.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

@main
struct piPhoneApp: App {
    @StateObject private var bluetoothManager: BluetoothManager = BluetoothManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bluetoothManager)
        }
    }
}
