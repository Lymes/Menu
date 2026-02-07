import UIKit

final class DirectPrinter: NSObject {

    static let shared = DirectPrinter()

    // MARK: - Public API

    func printText(_ text: String) {
        #if DEBUG
        // In DEBUG: genera PDF e mostra la preview Quick Look
        generatePDFAndPreview(text)
        #else
        // In RELEASE: usa la stampante salvata oppure chiedi di selezionarla
        if let url = PrinterStorage.loadURL() {
            printDirect(text, to: url)
        } else {
            pickPrinter { printer in
                guard let printer else { return }
                PrinterStorage.save(printer.url, name: printer.displayName)
                self.printDirect(text, to: printer.url)
            }
        }
        #endif
    }

    /// Consente all’utente di cambiare stampante in qualunque momento (Release).
    func changePrinter(completion: ((String?) -> Void)? = nil) {
        pickPrinter { printer in
            guard let printer else {
                completion?(nil)
                return
            }
            PrinterStorage.save(printer.url, name: printer.displayName)
            completion?(printer.displayName)
        }
    }

    /// Ritorna il nome della stampante salvata (se disponibile).
    func currentPrinterName(completion: @escaping (String?) -> Void) {
        if let cached = PrinterStorage.loadName(), !cached.isEmpty {
            completion(cached)
            return
        }
        guard let url = PrinterStorage.loadURL() else {
            completion(nil)
            return
        }
        resolvePrinterName(from: url, completion: completion)
    }

    // MARK: - Internals (RELEASE)

    private func pickPrinter(completion: @escaping (UIPrinter?) -> Void) {
        let picker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        picker.present(animated: true) { controller, userDidSelect, _ in
            completion(userDidSelect ? controller.selectedPrinter : nil)
        }
    }

    private func printDirect(_ text: String, to url: URL) {
        let controller = UIPrintInteractionController.shared

        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.jobName = "Stampa diretta"
        info.duplex = .none
        controller.printInfo = info

        let formatter = UISimpleTextPrintFormatter(text: text)
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        controller.printFormatter = formatter

        let printer = UIPrinter(url: url)
        controller.print(to: printer) { _, completed, error in
            if let error = error {
                print("Errore stampa: \(error.localizedDescription)")
            } else {
                print("Completata: \(completed)")
                self.resolvePrinterName(from: url) { name in
                    if let name { PrinterStorage.save(url, name: name) }
                }
            }
        }
    }

    private func resolvePrinterName(from url: URL, completion: @escaping (String?) -> Void) {
        let printer = UIPrinter(url: url)
        printer.contactPrinter { available in
            completion(available ? printer.displayName : nil)
        }
    }
}

