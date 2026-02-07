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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .appTheme(themeSettings.theme)
        }
    }
}
