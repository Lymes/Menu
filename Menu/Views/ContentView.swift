import SwiftUI

struct ContentView: View {
    // Stato app
    @State private var layoutStyle: LayoutStyle = .grid

    // Menu
    @State private var menus: [MenuItem] = defaultMenus
    @State private var selectedMenu: MenuItem? = defaultMenus.first

    // Bevande
    @State private var drinks: [DrinkItem] = defaultDrinks

    // UI stato
    @State private var showPreview: Bool = false
    @State private var isSending: Bool = false
    @StateObject private var model = PrinterModel()

    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.appTheme) private var theme

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundWash
                    .ignoresSafeArea()

                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 16) {
                            layoutPicker

                            MenuSection(
                                layoutStyle: layoutStyle,
                                containerWidth: geo.size.width,
                                menus: menus,
                                selectedMenu: $selectedMenu
                            )

                            DrinksSection(
                                layoutStyle: layoutStyle,
                                containerWidth: geo.size.width,
                                drinks: $drinks,
                                updateDrink: updateDrink(at:delta:)
                            )

                            Spacer(minLength: 0)
                        }
                        .padding()
                        .frame(minHeight: geo.size.height, alignment: .top)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Ordine Stanza 1", comment: "Order Room 1 title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("LegrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 16)
                        .blendMode(.multiply)
                        .opacity(0.95)
                        .offset(y: 0.5)
                        .accessibilityLabel("Legrand")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(NSLocalizedString("Tema", comment: "Theme"), selection: $themeSettings.scheme) {
                            ForEach(AppColorScheme.allCases) { scheme in
                                Text(scheme.displayName).tag(scheme)
                            }
                        }
                    } label: {
                        Label(
                            NSLocalizedString("Tema", comment: "Theme"),
                            systemImage: "paintpalette"
                        )
                    }
                    .accessibilityLabel(NSLocalizedString("Tema", comment: "Theme"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
        }
        .tint(theme.accent)
        .onAppear { model.refreshName() }
        // Provide a reliable UIKit presenter for iPad popovers (printer picker)
        .background(
            ViewControllerPresenter { vc in
                DirectPrinter.shared.presenterViewController = vc
            }
            .frame(width: 0, height: 0)
        )
        .sheet(isPresented: $showPreview) {
            TicketPreviewView(
                text: composeTicket(),
                onSend: {
                    isSending = true
                    DirectPrinter.shared.printText(composeTicket())

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isSending = false
                    }
                },
                onClose: { showPreview = false }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private var layoutPicker: some View {
        Picker(NSLocalizedString("Layout", comment: "Layout picker"), selection: $layoutStyle) {
            ForEach(LayoutStyle.allCases) { style in
                Text(style.localized).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }

    private var buttonTitle: String {
        isSending ? NSLocalizedString("Invia", comment: "Send button") : NSLocalizedString("Anteprima", comment: "Preview button")
    }

    // Aggiorna quantità bevanda (0...20)
    private func updateDrink(at index: Int, delta: Int) {
        var q = drinks[index].quantity + delta
        q = max(0, min(20, q))
        drinks[index].quantity = q
    }

    // Composizione ticket
    private func composeTicket() -> String {
        let now = Date().formatted(date: .abbreviated, time: .shortened)
        var lines: [String] = []
        lines.append(NSLocalizedString("=== Ordine Stanza 1 ===", comment: "Order Room 1 header"))
        lines.append("\n")
        lines.append(NSLocalizedString("Stanza: 1", comment: "Room number"))
        lines.append(String(format: NSLocalizedString("Data/Ora: %1$@", comment: "Date/Time"), now))
        lines.append("")

        if let menu = selectedMenu {
            lines.append(String(format: NSLocalizedString("Menu: %1$@", comment: "Menu name"), menu.title))
        } else {
            lines.append(NSLocalizedString("Menu: —", comment: "No menu selected"))
        }

        let chosen = drinks.filter { $0.quantity > 0 }
        if chosen.isEmpty {
            lines.append(NSLocalizedString("Bevande: nessuna", comment: "No drinks"))
        } else {
            lines.append(NSLocalizedString("Bevande:", comment: "Drinks label"))
            for d in chosen {
                lines.append(" • \(d.title) x\(d.quantity)")
            }
        }

        lines.append("")
        lines.append(NSLocalizedString("Grazie!", comment: "Thank you"))
        return lines.joined(separator: "\n")
    }

    private var bottomBar: some View {
        BottomBar(
            currentPrinterName: model.currentName,
            isSending: isSending,
            primaryButtonTitle: buttonTitle,
            onPrimary: { showPreview = true },
            onChangePrinter: {
                DirectPrinter.shared.changePrinter { newName in
                    model.setName(newName)
                }
            },
            onForgetPrinter: model.currentName != nil ? {
                model.clear()
            } : nil
        )
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .appTheme(AppTheme(.orange))
                .previewDisplayName("Orange")

            ContentView()
                .appTheme(AppTheme(.blue))
                .previewDisplayName("Blue")

            ContentView()
                .appTheme(AppTheme(.red))
                .previewDisplayName("Red")
        }
        .environment(\.locale, Locale(identifier: "de"))
    }
}
#endif
