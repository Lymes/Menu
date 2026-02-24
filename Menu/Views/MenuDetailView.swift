import SwiftUI

struct MenuDetailView: View {
    let menu: MenuItem
    @Binding var selectedMenu: MenuItem?

    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Bold title
                    Text(menu.title)
                        .font(.title.bold())
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    // Centered content with formatted sections
                    VStack(spacing: 0) {
                        ForEach(parseMenuContent(menu.detailContent), id: \.id) { section in
                            if section.isSectionTitle {
                                Text(section.text)
                                    .font(.headline.bold())
                                    .padding(.top, 20)
                                    .padding(.bottom, 8)
                            } else if section.text.isEmpty {
                                Spacer()
                                    .frame(height: 8)
                            } else {
                                Text(section.text)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 120)
                }
            }

            // Select button at bottom
            VStack(spacing: 0) {
                if selectedMenu == menu {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(theme.accent)
                        Text(NSLocalizedString("Selected", comment: "Selected"))
                            .font(.subheadline)
                            .foregroundColor(theme.accent)
                    }
                    .padding(.vertical, 8)
                }

                Button(action: {
                    print("🎯 Selecting menu: \(menu.title)")
                    selectedMenu = menu
                    print("✅ selectedMenu updated to: \(selectedMenu?.title ?? "NIL")")
                    dismiss()
                }) {
                    Text(NSLocalizedString("Select this menu", comment: "Select this menu"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image("LegrandLogo")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 100, height: 32)
                }
                .frame(width: 140, height: 40)
            }
        }
        .background(theme.backgroundWash.ignoresSafeArea())
    }

    private func parseMenuContent(_ content: String) -> [MenuContentSection] {
        var sections: [MenuContentSection] = []
        let lines = content.components(separatedBy: "\n")

        for line in lines {
            if line.hasPrefix("**") && line.hasSuffix("**") {
                // Section title (bold)
                let title = line.replacingOccurrences(of: "**", with: "")
                sections.append(MenuContentSection(text: title, isSectionTitle: true))
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                // Empty line
                sections.append(MenuContentSection(text: "", isSectionTitle: false))
            } else {
                // Regular text
                sections.append(MenuContentSection(text: line, isSectionTitle: false))
            }
        }

        return sections
    }
}

struct MenuContentSection: Identifiable {
    let id = UUID()
    let text: String
    let isSectionTitle: Bool
}

#if DEBUG
struct MenuDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MenuDetailView(menu: defaultMenus[0], selectedMenu: .constant(nil))
        }
        .appTheme(AppTheme(.orange))
    }
}
#endif
