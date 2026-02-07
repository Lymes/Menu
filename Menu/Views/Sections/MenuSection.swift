import SwiftUI

struct MenuSection: View {
    let layoutStyle: LayoutStyle
    let containerWidth: CGFloat
    let menus: [MenuItem]
    @Binding var selectedMenu: MenuItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Menu Fissi", comment: "Fixed Menus"))
                .font(.headline)
                .foregroundStyle(AppTheme.selectionStroke)

            switch layoutStyle {
            case .grid:
                AdaptiveGrid(containerWidth: containerWidth) {
                    ForEach(menus) { item in
                        SelectableCard(
                            title: item.title,
                            image: thumbnail(item.imageName, fallback: "takeoutbag.and.cup.and.straw"),
                            isSelected: selectedMenu == item,
                            onTap: { selectedMenu = item }
                        )
                    }
                }

            case .list:
                List(menus, id: \.id) { item in
                    SelectableRow(
                        title: item.title,
                        image: thumbnail(item.imageName, fallback: "takeoutbag.and.cup.and.straw"),
                        isSelected: selectedMenu == item
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedMenu = item }
                }
                .listStyle(.plain)
                .frame(height: 220)
            }
        }
    }
}
