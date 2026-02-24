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
    @State private var showEmptyOrderAlert: Bool = false

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
            .navigationTitle(String(format: NSLocalizedString("Order Room %d", comment: "Order Room title"), RoomConfig.roomNumber))
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
            .onChange(of: drinks) { oldValue, newValue in
                let oldCount = oldValue.filter { $0.quantity > 0 }.count
                let newCount = newValue.filter { $0.quantity > 0 }.count
                print("📝 drinks changed - items with qty>0: \(oldCount) → \(newCount)")
                for (idx, drink) in newValue.enumerated() where drink.quantity > 0 {
                    print("   [\(idx)] \(drink.title) x\(drink.quantity)")
                }
            }
        }
        .tint(theme.accent)
        .sheet(isPresented: $showPreview) {
            let ticketText = composeTicket()
            print("📄 Sheet opening - generating ticket now")
            return TicketPreviewView(
                text: ticketText,
                onSend: {
                    // Check if server is available
                    guard !orderSender.discoveredServers.isEmpty else {
                        showPreview = false
                        showServerError = true
                        return
                    }

                    isSending = true

                    let menuItems = selectedMenu.map { [NSLocalizedString($0.title, comment: "Menu name")] } ?? []
                    let selectedDrinks = drinks.filter { $0.quantity > 0 }
                        .map { (name: NSLocalizedString($0.title, comment: "Drink name"), quantity: $0.quantity) }

                    orderSender.sendOrder(
                        roomNumber: "\(RoomConfig.roomNumber)",
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
        .alert(NSLocalizedString("Nothing Selected", comment: "Nothing selected alert title"), isPresented: $showEmptyOrderAlert) {
            Button(NSLocalizedString("OK", comment: "OK"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("Please select at least one menu or drink before sending the order.", comment: "Empty order alert message"))
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
        print("🍹 updateDrink called - index: \(index), delta: \(delta), current qty: \(drinks[index].quantity)")

        // Force a new copy of the entire array to trigger @State update
        var updatedDrinks = drinks
        let newQuantity = max(0, updatedDrinks[index].quantity + delta)
        updatedDrinks[index].quantity = newQuantity
        drinks = updatedDrinks

        print("✅ Drink updated - \(drinks[index].title) now has quantity: \(drinks[index].quantity)")
    }

    // Composizione ticket
    private func composeTicket() -> String {
        print("🔍 Composing ticket - selectedMenu: \(selectedMenu?.title ?? "NIL")")

        let now = Date().formatted(date: .abbreviated, time: .shortened)
        var lines: [String] = []
        lines.append(String(format: NSLocalizedString("=== Order Room %d ===", comment: "Order Room header"), RoomConfig.roomNumber))
        lines.append(String(format: NSLocalizedString("Room: %d", comment: "Room number"), RoomConfig.roomNumber))
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
        print("🍹 Drinks with quantity > 0: \(chosen.count)")
        for d in chosen {
            print("   • \(d.title) x\(d.quantity)")
        }

        if chosen.isEmpty {
            lines.append(NSLocalizedString("Drinks: none", comment: "No drinks"))
        } else {
            lines.append(NSLocalizedString("Drinks:", comment: "Drinks label"))
            for d in chosen {
                let localizedName = NSLocalizedString(d.title, comment: "Drink name")
                lines.append(" • \(localizedName) x\(d.quantity)")
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
            onPrimary: showPreviewWithValidation,
            onChangePrinter: nil,
            onForgetPrinter: nil,
            onCallWaiter: callWaiter
        )
    }

    private func showPreviewWithValidation() {
        // Check if something is selected
        let hasSelectedMenu = selectedMenu != nil
        let hasSelectedDrinks = drinks.contains { $0.quantity > 0 }

        if !hasSelectedMenu && !hasSelectedDrinks {
            showEmptyOrderAlert = true
            return
        }

        // Valid selection, show preview
        showPreview = true
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
            roomNumber: "\(RoomConfig.roomNumber)",
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
