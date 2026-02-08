import SwiftUI

struct SelectableCard: View {
    let title: String
    let image: Image
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Background image
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                // Stronger readability scrim (bottom third)
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.00), location: 0.00),
                        .init(color: .black.opacity(0.10), location: 0.45),
                        .init(color: .black.opacity(0.70), location: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Title overlay
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.black.opacity(0.35))
                            .blendMode(.normal)
                    )
                    .padding(10)

                // Selection badge
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, theme.accent)
                        .font(.title3)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? theme.selectionFill.opacity(0.22) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? theme.selectionStroke : Color.black.opacity(0.08), lineWidth: isSelected ? 3 : 1)
            )
            .shadow(
                color: isSelected ? theme.selectionStroke.opacity(0.35) : .black.opacity(0.08),
                radius: isSelected ? 14 : 6,
                x: 0,
                y: isSelected ? 8 : 3
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.snappy(duration: 0.18), value: isSelected)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .clipped()
        }
        .buttonStyle(.plain)
    }
}
