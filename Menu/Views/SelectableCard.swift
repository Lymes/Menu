import SwiftUI

struct SelectableCard: View {
    let title: String
    let image: Image
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 72)
                    .padding(8)
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(
                isSelected
                    ? theme.selectionFill
                    : Color(.secondarySystemBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? theme.selectionStroke : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
