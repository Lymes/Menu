//
//  TicketPreviewView.swift
//  Menu
//
//  Created by leonid.mesentsev on 06/02/26.
//


import SwiftUI

struct TicketPreviewView: View {
    let text: String
    let onSend: () -> Void
    let onClose: () -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
            }
            .tint(theme.accent)
            .navigationTitle(NSLocalizedString("Preview", comment: "Preview"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Close", comment: "Close"), action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Send", comment: "Send"), action: onSend)
                        .bold()
                }
            }
        }
        .tint(theme.accent)
    }
}
