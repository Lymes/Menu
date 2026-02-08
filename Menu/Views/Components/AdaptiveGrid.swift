import SwiftUI

/// Grid non-scrollabile, da usare DENTRO a uno ScrollView esterno.
struct AdaptiveGrid<Content: View>: View {
    let containerWidth: CGFloat
    var minItemSize: CGFloat = 150
    var maxColumns: Int = 6
    @ViewBuilder var content: () -> Content

    var body: some View {
        let horizontalPadding: CGFloat = 12
        let spacing: CGFloat = 14
        let cellCornerRadius: CGFloat = 14

        let available = max(0, containerWidth - horizontalPadding * 2)
        let maxItemSize = max(minItemSize, available / 3)

        let computedColumns = Int((available + spacing) / (minItemSize + spacing))
        let columnsCount = max(1, min(maxColumns, computedColumns))

        let rawItemSize = columnsCount > 0
            ? (available - spacing * CGFloat(max(0, columnsCount - 1))) / CGFloat(columnsCount)
            : available
        let itemSize = min(maxItemSize, max(minItemSize, rawItemSize))

        let finalColumns = max(1, min(maxColumns, Int((available + spacing) / (itemSize + spacing))))
        let rawFinalItemSize = finalColumns > 0
            ? (available - spacing * CGFloat(max(0, finalColumns - 1))) / CGFloat(finalColumns)
            : available
        let finalItemSize = min(maxItemSize, max(minItemSize, rawFinalItemSize))

        let columns = Array(
            repeating: GridItem(.fixed(finalItemSize), spacing: spacing, alignment: .center),
            count: finalColumns
        )

        LazyVGrid(columns: columns, alignment: .center, spacing: spacing) {
            content()
                .frame(width: finalItemSize, height: finalItemSize)
                .clipShape(RoundedRectangle(cornerRadius: cellCornerRadius, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: cellCornerRadius, style: .continuous))
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity)
    }
}
