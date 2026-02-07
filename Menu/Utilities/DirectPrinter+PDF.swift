//
//  DirectPrinter+PDF.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//

import QuickLook


// MARK: - DEBUG: PDF + Quick Look Preview

#if DEBUG
extension DirectPrinter {

    /// Genera PDF dal testo (usando lo stesso formatter della stampa) e mostra QLPreviewController
    func generatePDFAndPreview(_ text: String) {
        let formatter = UISimpleTextPrintFormatter(text: text)
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)

        do {
            let data = try Self.makePDF(
                from: formatter,
                paperBounds: Self.a4PortraitBounds,
                printableInsets: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
            )

            // Scrivi in /tmp con estensione .pdf
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(Self.timestampedPDFFileName())
            try data.write(to: url, options: .atomic)

            presentQuickLook(for: url)

        } catch {
            print("Errore generazione/scrittura PDF (DEBUG): \(error.localizedDescription)")
        }
    }

    // A4 @72dpi
    static var a4PortraitBounds: CGRect { CGRect(x: 0, y: 0, width: 595, height: 842) }

    static func makePDF(from formatter: UIPrintFormatter,
                        paperBounds: CGRect,
                        printableInsets: UIEdgeInsets) throws -> Data {

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        // Configura carta/area stampabile
        let printableRect = paperBounds.inset(by: printableInsets)
        renderer.setValue(NSValue(cgRect: paperBounds), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: paperBounds)
        let data = pdfRenderer.pdfData { ctx in
            let pageCount = renderer.numberOfPages
            for page in 0..<pageCount {
                ctx.beginPage()
                renderer.drawPage(at: page, in: paperBounds)
            }
        }
        return data
    }

    static func timestampedPDFFileName(prefix: String = "Ordine") -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd-HHmmss"
        return "\(prefix)-\(fmt.string(from: Date())).pdf"
    }

    // MARK: QLPreview

    func presentQuickLook(for url: URL) {
        guard let presenter = Self.topMostViewController() else {
            print("Nessun VC disponibile per presentare la preview.")
            return
        }

        // Passa l'URL al datasource del controller
        PDFPreviewController.sharedItemURL = url

        let preview = PDFPreviewController()
        preview.dataSource = preview
        preview.delegate = preview
        preview.currentPreviewItemIndex = 0
        preview.modalPresentationStyle = .formSheet

        // Se c'è già qualcosa di presentato (es. .sheet SwiftUI), usa quello come host
        let host = presenter.presentedViewController ?? presenter
        DispatchQueue.main.async {
            host.present(preview, animated: true, completion: nil)
        }
    }

    static func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var current = root
        while let next = current.presentedViewController {
            current = next
        }
        return current
    }
}

#endif
