import SwiftUI

struct ServerContentView: View {
    @EnvironmentObject var orderStore: OrderStore
    @EnvironmentObject var bonjourService: BonjourService
    @State private var serviceCheckTimer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Service status
                    HStack {
                        Circle()
                            .fill(bonjourService.isAdvertising ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(bonjourService.isAdvertising ? NSLocalizedString("Server active", comment: "Server active") : NSLocalizedString("Server not active", comment: "Server not active"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .onTapGesture {
                        // Allow manual restart by tapping status
                        if !bonjourService.isAdvertising {
                            print("👆 Manual restart requested")
                            bonjourService.startAdvertising()
                        }
                    }

                    // Orders list
                    if orderStore.orders.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text(NSLocalizedString("No orders received", comment: "No orders received"))
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(orderStore.orders, id: \.id) { order in
                                OrderRowView(order: order)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            orderStore.deleteOrder(order)
                                        } label: {
                                            Label(NSLocalizedString("Delete", comment: "Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Menu Server", comment: "Menu Server title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("LegrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 18)
                        .blendMode(.multiply)
                        .opacity(0.95)
                }
            }
            .tint(.orange)
            .onAppear {
                startServiceMonitoring()
                setupBackgroundNotifications()
            }
            .onDisappear {
                stopServiceMonitoring()
            }
        }
    }
    
    // MARK: - Service Monitoring
    
    private func startServiceMonitoring() {
        print("🔄 Starting service monitoring")
        serviceCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
//               $bonjourService.ensureServiceIsRunning
            }
        }
    }
    
    private func stopServiceMonitoring() {
        print("⏹️ Stopping service monitoring")
        serviceCheckTimer?.invalidate()
        serviceCheckTimer = nil
    }
    
    private func setupBackgroundNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("📱 ServerContentView: App backgrounded")
            // Keep monitoring timer active but reduce frequency
            stopServiceMonitoring()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("📱 ServerContentView: App foregrounded")
            // Resume monitoring when back in foreground
            startServiceMonitoring()
        }
    }
}

struct OrderRowView: View {
    let order: Order
    @EnvironmentObject var orderStore: OrderStore

    private var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .preparing: return .blue
        case .completed: return .green
        case .cancelled: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(String(format: NSLocalizedString("Room", comment: "Room") + " %@", order.roomNumber))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(order.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(NSLocalizedString(order.status.rawValue, comment: "Order status"))
                    .font(.caption)
                    .foregroundColor(statusColor)

                Spacer()

                // Status picker
                Menu {
                    ForEach([OrderStatus.pending, .preparing, .completed, .cancelled], id: \.self) { status in
                        Button(NSLocalizedString(status.rawValue.capitalized, comment: "Status option")) {
                            orderStore.updateOrderStatus(order, status: status)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.orange)
                }
                .accessibilityLabel(NSLocalizedString("Change status", comment: "Change status"))
            }

            // Menu items
            if !order.menuItems.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("Menu:", comment: "Menu label"))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(order.menuItems, id: \.self) { item in
                        Text("• \(item)")
                            .font(.subheadline)
                    }
                }
            }

            // Drinks
            if !order.drinks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("Drinks:", comment: "Drinks label"))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(order.drinks, id: \.self) { drink in
                        Text("• \(drink.name) × \(drink.quantity)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
