import SwiftUI

struct BottomBar: View {
    let currentPrinterName: String?
    let isSending: Bool
    let primaryButtonTitle: String
    let onPrimary: () -> Void
    let onChangePrinter: () -> Void
    let onForgetPrinter: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if let name = currentPrinterName {
                    Text(String(format: NSLocalizedString("Stampante corrente: %1$@", comment: "Current printer"), name))
                } else {
                    Text(NSLocalizedString("Nessuna stampante selezionata", comment: "No printer selected"))
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(primaryButtonTitle, action: onPrimary)
                .font(.title3)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSending ? Color.orange.opacity(0.6) : Color.orange.opacity(0.9))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contextMenu {
                    Button(NSLocalizedString("Cambia stampante", comment: "Change printer"), action: onChangePrinter)
                    if let onForgetPrinter {
                        Button(NSLocalizedString("Dimentica stampante", comment: "Forget printer"), role: .destructive, action: onForgetPrinter)
                    }
                }

            Button(NSLocalizedString("Cambia stampante", comment: "Change printer"), action: onChangePrinter)
                .font(.callout)
                .frame(maxWidth: .infinity)
                .tint(.orange)
        }
        .padding(14)
        .background(.thinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.selectionStroke.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
