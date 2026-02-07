//
//  PDFPreviewController.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//

import QuickLook


// QLPreviewController che funge anche da DataSource/Delegate
final class PDFPreviewController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    // URL condiviso del PDF da mostrare
    static var sharedItemURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.title = "Anteprima PDF (DEBUG)"
    }

    // MARK: QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return PDFPreviewController.sharedItemURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // Ritorna un oggetto conforme con URL opzionale (richiesto dal protocollo)
        return PDFPreviewItem(url: PDFPreviewController.sharedItemURL)
    }

    // MARK: QLPreviewControllerDelegate
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Rilascia il riferimento quando chiudi la preview
        PDFPreviewController.sharedItemURL = nil
    }
}

// Oggetto QLPreviewItem per il PDF — previewItemURL deve essere opzionale
final class PDFPreviewItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?

    init(url: URL?) {
        self.previewItemURL = url
        super.init()
    }
}
