import UIKit

final class DirectPrinter: NSObject {

    static let shared = DirectPrinter()

    // MARK: - Presentation configuration

    /// If set, this controller will be used to present the printer picker.
    /// This is the most robust path on iPad (multi-window / multiple scenes).
    weak var presenterViewController: UIViewController?

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

    // MARK: - Internals

    private func pickPrinter(completion: @escaping (UIPrinter?) -> Void) {
        let picker = UIPrinterPickerController(initiallySelectedPrinter: nil)

        DispatchQueue.main.async {
            guard let presenter = (self.presenterViewController ?? Self.topMostViewController()) else {
                print("Nessun VC disponibile per presentare UIPrinterPickerController")
                completion(nil)
                return
            }

            // If something is already presented (like a SwiftUI sheet), present from that host.
            let host = presenter.presentedViewController ?? presenter

            // Present using the iPad-safe API that anchors the popover.
            // We anchor to the bottom-center of the host view to avoid weird arrow placement.
            let bounds = host.view.bounds
            let anchor = CGRect(x: bounds.midX - 1, y: bounds.maxY - 2, width: 2, height: 2)

            picker.present(from: anchor, in: host.view, animated: true) { controller, userDidSelect, _ in
                completion(userDidSelect ? controller.selectedPrinter : nil)
            }
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

    // MARK: - Presentation helper

    static func topMostViewController() -> UIViewController? {
        // Prefer foreground active scene for iPad multi-window.
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let ordered = scenes.sorted {
            ($0.activationState == .foregroundActive ? 0 : 1) < ($1.activationState == .foregroundActive ? 0 : 1)
        }

        for scene in ordered {
            guard let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { continue }
            var current = root
            while let next = current.presentedViewController {
                current = next
            }
            return current
        }
        return nil
    }
}
