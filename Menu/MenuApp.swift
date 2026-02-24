//
//  MenuApp.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//

import SwiftUI

@main
struct MenuApp: App {
    @StateObject private var themeSettings = ThemeSettings()
    @StateObject private var orderSender = OrderSenderService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .environmentObject(orderSender)
                .appTheme(themeSettings.theme)
                .onAppear {
                    orderSender.startDiscovery()
                }
        }
    }
}
