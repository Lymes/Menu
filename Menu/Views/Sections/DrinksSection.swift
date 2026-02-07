import SwiftUI

struct DrinksSection: View {
    let layoutStyle: LayoutStyle
    let containerWidth: CGFloat
    @Binding var drinks: [DrinkItem]
    let updateDrink: (_ index: Int, _ delta: Int) -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Bevande", comment: "Drinks section title"))
                .font(.headline)
                .foregroundStyle(theme.selectionStroke)

            switch layoutStyle {
            case .grid:
                AdaptiveGrid(containerWidth: containerWidth) {
                    ForEach(drinks.indices, id: \.self) { idx in
                        DrinkCard(
                            title: drinks[idx].title,
                            image: thumbnail(drinks[idx].imageName, fallback: "cup.and.saucer"),
                            quantity: drinks[idx].quantity,
                            onMinus: { updateDrink(idx, -1) },
                            onPlus: { updateDrink(idx, +1) }
                        )
                    }
                }

            case .list:
                List {
                    ForEach(drinks.indices, id: \.self) { idx in
                        DrinkRow(
                            title: drinks[idx].title,
                            image: thumbnail(drinks[idx].imageName, fallback: "cup.and.saucer"),
                            quantity: drinks[idx].quantity,
                            onMinus: { updateDrink(idx, -1) },
                            onPlus: { updateDrink(idx, +1) }
                        )
                    }
                }
                .listStyle(.plain)
                .frame(height: 300)
            }
        }
    }
}
