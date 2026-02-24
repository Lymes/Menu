import SwiftUI

@main
struct MenuServerApp: App {
    @StateObject private var orderStore = OrderStore()
    @StateObject private var bonjourService = BonjourService()

    var body: some Scene {
        WindowGroup {
            ServerContentView()
                .environmentObject(orderStore)
                .environmentObject(bonjourService)
                .onAppear {
                    bonjourService.orderStore = orderStore
                    bonjourService.startAdvertising()
                }
        }
    }
}
