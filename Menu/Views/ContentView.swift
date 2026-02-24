import SwiftUI

struct ContentView: View {
    // Stato app
    @State private var layoutStyle: LayoutStyle = .grid

    // Menu
    @State private var menus: [MenuItem] = defaultMenus
    @State private var selectedMenu: MenuItem? = nil

    // Bevande
    @State private var drinks: [DrinkItem] = defaultDrinks

    // UI stato
    @State private var showPreview: Bool = false
    @State private var isSending: Bool = false
    @State private var showServerError: Bool = false

    @EnvironmentObject private var themeSettings: ThemeSettings
    @EnvironmentObject private var orderSender: OrderSenderService
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
                                containerWidth: max(0, geo.size.width - 32),
                                menus: menus,
                                selectedMenu: $selectedMenu
                            )

                            DrinksSection(
                                layoutStyle: layoutStyle,
                                containerWidth: max(0, geo.size.width - 32),
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
            .navigationTitle(NSLocalizedString("Order Room 1", comment: "Order Room 1 title"))
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
                        Picker(NSLocalizedString("Theme", comment: "Theme"), selection: $themeSettings.scheme) {
                            ForEach(AppColorScheme.allCases) { scheme in
                                Text(scheme.displayName).tag(scheme)
                            }
                        }
                    } label: {
                        Label(
                            NSLocalizedString("Theme", comment: "Theme"),
                            systemImage: "paintpalette"
                        )
                    }
                    .accessibilityLabel(NSLocalizedString("Theme", comment: "Theme"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .onChange(of: selectedMenu) { oldValue, newValue in
                print("📝 selectedMenu changed from '\(oldValue?.title ?? "NIL")' to '\(newValue?.title ?? "NIL")'")
            }
        }
        .tint(theme.accent)
        .sheet(isPresented: $showPreview) {
            TicketPreviewView(
                text: composeTicket(),
                onSend: {
                    // Check if server is available
                    guard !orderSender.discoveredServers.isEmpty else {
                        showPreview = false
                        showServerError = true
                        return
                    }

                    isSending = true

                    let menuItems = selectedMenu.map { [$0.title] } ?? []
                    let selectedDrinks = drinks.filter { $0.quantity > 0 }
                        .map { (name: $0.title, quantity: $0.quantity) }

                    orderSender.sendOrder(
                        roomNumber: "1",
                        menuItems: menuItems,
                        drinks: selectedDrinks
                    ) { success in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isSending = false
                            if success {
                                showPreview = false
                            } else {
                                showPreview = false
                                showServerError = true
                            }
                        }
                    }
                },
                onClose: { showPreview = false }
            )
            .presentationDetents([.medium, .large])
        }
        .alert(NSLocalizedString("Server not found", comment: "Server not found"), isPresented: $showServerError) {
            Button(NSLocalizedString("OK", comment: "OK"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("Cannot find Menu Server on the network. Make sure the server is running and both devices are on the same WiFi network.", comment: "Server error message"))
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
        isSending ? NSLocalizedString("Send", comment: "Send button") : NSLocalizedString("Preview", comment: "Preview button")
    }

    // Aggiorna quantità bevanda (0...∞)
    private func updateDrink(at index: Int, delta: Int) {
        let q = max(0, drinks[index].quantity + delta)
        drinks[index].quantity = q
    }

    // Composizione ticket
    private func composeTicket() -> String {
        print("🔍 Composing ticket - selectedMenu: \(selectedMenu?.title ?? "NIL")")

        let now = Date().formatted(date: .abbreviated, time: .shortened)
        var lines: [String] = []
        lines.append(NSLocalizedString("=== Order Room 1 ===", comment: "Order Room 1 header"))
        lines.append(NSLocalizedString("Room: 1", comment: "Room number"))
        lines.append(String(format: NSLocalizedString("Date/Time: %1$@", comment: "Date/Time"), now))
        lines.append("")

        if let menu = selectedMenu {
            lines.append(String(format: NSLocalizedString("Menu: %1$@", comment: "Menu name"), menu.title))
            print("✅ Menu added to ticket: \(menu.title)")
        } else {
            lines.append(NSLocalizedString("Menu: —", comment: "No menu selected"))
            print("⚠️ No menu selected")
        }

        let chosen = drinks.filter { $0.quantity > 0 }
        if chosen.isEmpty {
            lines.append(NSLocalizedString("Drinks: none", comment: "No drinks"))
        } else {
            lines.append(NSLocalizedString("Drinks:", comment: "Drinks label"))
            for d in chosen {
                lines.append(" • \(d.title) x\(d.quantity)")
            }
        }

        lines.append("")
        lines.append(NSLocalizedString("Thank you!", comment: "Thank you"))
        return lines.joined(separator: "\n")
    }

    private var bottomBar: some View {
        BottomBar(
            isSending: isSending,
            primaryButtonTitle: buttonTitle,
            onPrimary: { showPreview = true },
            onChangePrinter: nil,
            onForgetPrinter: nil,
            onCallWaiter: callWaiter
        )
    }

    private func callWaiter() {
        // Check if server is available
        guard !orderSender.discoveredServers.isEmpty else {
            showServerError = true
            return
        }

        isSending = true

        // Send special service request
        orderSender.sendOrder(
            roomNumber: "1",
            menuItems: [NSLocalizedString("Room service: call waiter", comment: "Room service: call waiter")],
            drinks: []
        ) { success in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSending = false
                if !success {
                    showServerError = true
                }
            }
        }
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
