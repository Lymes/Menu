//
//  PrinterModel.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//

import Foundation
import Combine   

final class PrinterModel: ObservableObject {
    @Published var currentName: String?

    func refreshName() {
        DirectPrinter.shared.currentPrinterName { [weak self] name in
            DispatchQueue.main.async {
                self?.currentName = name
            }
        }
    }

    func setName(_ name: String?) {
        DispatchQueue.main.async {
            self.currentName = name
        }
    }

    func clear() {
        PrinterStorage.clear()
        setName(nil)
    }
}
