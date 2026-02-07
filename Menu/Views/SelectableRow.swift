import SwiftUI

struct SelectableRow: View {
    let title: String
    let image: Image
    let isSelected: Bool

    var body: some View {
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
                    .foregroundStyle(AppTheme.selectionStroke)
            }
        }
        .padding(.vertical, 6)
    }
}
