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
            ZStack(alignment: .topLeading) {
                // Background color (stable base)
                Color(.secondarySystemBackground)

                // Image layer (absolutely positioned, can't influence layout)
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .allowsHitTesting(false)

                // Gradient overlay
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.00), location: 0.00),
                        .init(color: .black.opacity(0.10), location: 0.45),
                        .init(color: .black.opacity(0.70), location: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                // Title (top-leading)
                VStack {
                    HStack {
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
                            )
                            .padding(10)
                        Spacer()
                    }
                    Spacer()
                }
                .allowsHitTesting(false)

                // ControlsBar (absolutely positioned at bottom)
                VStack {
                    Spacer()
                    controlsBar
                        .frame(height: bottomBarHeight)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 5)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .zIndex(10)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .clipped()
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
