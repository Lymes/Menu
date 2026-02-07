import SwiftUI

struct SelectableRow: View {
    let title: String
    let image: Image
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .cornerRadius(6)
                Text(title)
                    .font(.body)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.selectionStroke)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
