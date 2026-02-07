//
//  PrinterStorage.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//


import Foundation

final class PrinterStorage {
    private static let key = "savedPrinterURL"
    private static let nameKey = "savedPrinterName" // opzionale: cache del nome

    static func save(_ url: URL, name: String?) {
        UserDefaults.standard.set(url.absoluteString, forKey: key)
        if let name { UserDefaults.standard.set(name, forKey: nameKey) }
    }

    static func loadURL() -> URL? {
        guard let str = UserDefaults.standard.string(forKey: key) else { return nil }
        return URL(string: str)
    }

    static func loadName() -> String? {
        UserDefaults.standard.string(forKey: nameKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: nameKey)
    }
}
