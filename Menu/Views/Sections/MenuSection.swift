import SwiftUI

struct MenuSection: View {
    let layoutStyle: LayoutStyle
    let containerWidth: CGFloat
    let menus: [MenuItem]
    @Binding var selectedMenu: MenuItem?
    @Environment(\.appTheme) private var theme

    private func menuThumbnail(for item: MenuItem) -> Image {
        // Use the same thumbnail for all menu items.
        thumbnail("menu1", fallback: "takeoutbag.and.cup.and.straw")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Menu Fissi", comment: "Menu section title"))
                .font(.headline)
                .foregroundStyle(theme.selectionStroke)

            switch layoutStyle {
            case .grid:
                AdaptiveGrid(containerWidth: containerWidth, minItemSize: 150, maxColumns: 3) {
                    ForEach(menus) { item in
                        SelectableCard(
                            title: item.title,
                            image: menuThumbnail(for: item),
                            isSelected: selectedMenu == item,
                            onTap: { selectedMenu = item }
                        )
                    }
                }

            case .list:
                List(menus, id: \.id) { item in
                    SelectableRow(
                        title: item.title,
                        image: menuThumbnail(for: item),
                        isSelected: selectedMenu == item,
                        onTap: { selectedMenu = item }
                    )
                }
                .listStyle(.plain)
                .frame(height: 220)
            }
        }
    }
}
