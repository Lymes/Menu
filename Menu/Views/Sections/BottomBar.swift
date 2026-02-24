import SwiftUI

struct BottomBar: View {
    let isSending: Bool
    let primaryButtonTitle: String
    let onPrimary: () -> Void
    let onChangePrinter: (() -> Void)?
    let onForgetPrinter: (() -> Void)?
    let onCallWaiter: (() -> Void)?

    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(primaryButtonTitle, action: onPrimary)
                .font(.title3)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(theme.primaryButtonBackground(isEnabled: true, isLoading: isSending))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let onCallWaiter = onCallWaiter {
                Button(action: onCallWaiter) {
                    Label(NSLocalizedString("Chiama cameriere", comment: "Call waiter"), systemImage: "bell.fill")
                }
                .font(.callout)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(theme.accent.opacity(0.15))
                .foregroundColor(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let onChangePrinter = onChangePrinter {
                Button(NSLocalizedString("Cambia stampante", comment: "Change printer"), action: onChangePrinter)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
                    .tint(theme.accent)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.selectionStroke.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
