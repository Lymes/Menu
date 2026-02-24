import SwiftUI

struct DrinkCard: View {
    let title: String
    let image: Image
    let quantity: Int
    let onMinus: () -> Void
    let onPlus: () -> Void

    @Environment(\.appTheme) private var theme

    private let cornerRadius: CGFloat = 14
    private let bottomBarHeight: CGFloat = 50

    var body: some View {
        // Fixed-size container (1:1) that NEVER changes based on content
        GeometryReader { geo in
            ZStack {
                // Gradient background (subtle theme color)
                LinearGradient(
                    colors: [
                        theme.accent.opacity(0.08),
                        theme.accent.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 12)

                    // Icon centered with theme tint
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(theme.accent)
                        .padding(.horizontal, 12)

                    // Title text centered below icon (2 rows fixed)
                    Text(NSLocalizedString(title, comment: "Drink name"))
                        .font(.caption.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()

                    // ControlsBar at bottom
                    controlsBar
                        .frame(height: bottomBarHeight)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 5)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(theme.accent.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: theme.accent.opacity(0.15), radius: 8, x: 0, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var controlsBar: some View {
        HStack(spacing: 10) {
            Button(action: onMinus) {
                Image(systemName: "minus")
                    .font(.title3.weight(.bold))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(theme.accent))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)

            Text("\(quantity)")
                .font(.title3.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
                .frame(minWidth: 30)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.35))
                )

            Button(action: onPlus) {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(theme.accent))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
}

#if DEBUG
struct DrinkCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DrinkCard(title: "Coca-Cola", image: Image("coca-cola"), quantity: 1, onMinus: {}, onPlus: {})
                .frame(width: 160, height: 160)
                .previewDisplayName("Coca-Cola 160×160")

            DrinkCard(title: "Acqua", image: Image("water"), quantity: 0, onMinus: {}, onPlus: {})
                .frame(width: 160, height: 160)
                .previewDisplayName("Acqua 160×160")

            DrinkCard(title: "Birra", image: Image("beer"), quantity: 2, onMinus: {}, onPlus: {})
                .frame(width: 160, height: 160)
                .previewDisplayName("Birra 160×160")
        }
        .padding(12)
        .previewLayout(.sizeThatFits)
    }
}
#endif
