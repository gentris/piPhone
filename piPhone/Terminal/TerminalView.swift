//
//  TerminalView.swift
//  piPhone
//
//  Created by Gentris Leci on 1/6/26.
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        TerminalViewControllerRepresentable(bluetoothManager: bluetoothManager).ignoresSafeArea()
    }
}
