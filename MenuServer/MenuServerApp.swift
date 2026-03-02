import SwiftUI
import AVFoundation

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
                    print("🎯 MenuServer app started")
                    bonjourService.orderStore = orderStore
                    configureAudioSession()
                    startService()
                    setupBackgroundHandling()
                }
                .onDisappear {
                    print("⏹️ MenuServer app stopping")
                    // Don't stop service on disappear - keep running in background
                }
        }
    }

    private func startService() {
        // Add a small delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🚀 Starting Bonjour service...")
            bonjourService.startAdvertising()
        }
    }

    private func setupBackgroundHandling() {
        // Listen for app lifecycle notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("📱 App entered background - keeping service active")
                // Keep service running, don't stop
                bonjourService.handleBackgroundTransition()
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("📱 App entering foreground - refreshing service")
                // Refresh service state when returning to foreground
                bonjourService.handleForegroundTransition()
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("💀 App terminating - stopping service")
                bonjourService.stopAdvertising()
            }
        }
    }

    private func configureAudioSession() {
        do {
            // Configure audio session for background audio notifications
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("🔊 Audio session configured for notifications")
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
        }
    }
}
