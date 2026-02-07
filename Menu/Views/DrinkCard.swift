import SwiftUI

struct DrinkCard: View {
    let title: String
    let image: Image
    let quantity: Int
    let onMinus: () -> Void
    let onPlus: () -> Void

    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 64)
                .padding(8)
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button(action: onMinus) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                Text("\(quantity)")
                    .font(.title3.monospacedDigit())
                    .frame(minWidth: 28)
                Button(action: onPlus) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .tint(theme.accent)
            .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(quantity > 0 ? theme.selectionStroke : Color.clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
