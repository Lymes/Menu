import Foundation
import SwiftData
import Combine

@MainActor
class OrderStore: ObservableObject {
    @Published var orders: [Order] = []

    private var modelContext: ModelContext?

    init() {
        setupModelContext()
        loadOrders()
    }

    private func setupModelContext() {
        do {
            let schema = Schema([Order.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContext = ModelContext(container)
            print("✅ OrderStore: ModelContext initialized")
        } catch {
            print("❌ OrderStore: Failed to create model container: \(error)")
        }
    }

    func loadOrders() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Order>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            orders = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch orders: \(error)")
        }
    }

    func addOrder(_ order: Order) {
        guard let context = modelContext else { return }

        context.insert(order)

        do {
            try context.save()
            loadOrders()
        } catch {
            print("Failed to save order: \(error)")
        }
    }

    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        order.status = status

        guard let context = modelContext else { return }

        do {
            try context.save()
            loadOrders()
        } catch {
            print("Failed to update order: \(error)")
        }
    }

    func deleteOrder(_ order: Order) {
        guard let context = modelContext else { return }

        context.delete(order)

        do {
            try context.save()
            loadOrders()
        } catch {
            print("Failed to delete order: \(error)")
        }
    }
}
