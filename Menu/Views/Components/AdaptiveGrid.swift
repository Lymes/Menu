import SwiftUI

/// Grid non-scrollabile, da usare DENTRO a uno ScrollView esterno.
struct AdaptiveGrid<Content: View>: View {
    let containerWidth: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        let horizontalPadding: CGFloat = 12
        let spacing: CGFloat = 14

        let available = max(0, containerWidth - horizontalPadding * 2)
        let targetCardWidth = max(150, (available - spacing * 2) / 3)

        let columnsCount = max(1, Int((available + spacing) / (targetCardWidth + spacing)))
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .center), count: columnsCount)

        LazyVGrid(columns: columns, alignment: .center, spacing: spacing) {
            content()
                .frame(minWidth: 150, maxWidth: targetCardWidth)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity)
    }
}
