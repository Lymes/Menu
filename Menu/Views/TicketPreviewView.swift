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

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
            }
            .tint(AppTheme.orange)
            .navigationTitle(NSLocalizedString("Anteprima", comment: "Preview"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Chiudi", comment: "Close"), action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Invia", comment: "Send"), action: onSend)
                        .bold()
                }
            }
        }
        .tint(AppTheme.orange)
    }
}
