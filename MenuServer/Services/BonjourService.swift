import Foundation
import Network
import Combine
import UIKit
import AVFoundation

@MainActor
class BonjourService: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @Published var isAdvertising = false
    private var listener: NWListener?
    private var connections: [NWConnection] = []

    weak var orderStore: OrderStore?

    // MARK: - Audio notification
    private func playOrderNotificationSound() {
        // Use system sound for new order notification
//        AudioServicesPlaySystemSound(1016) // SMS tone

        // Alternatively, you could use:
         AudioServicesPlaySystemSound(1007) // SMS received tone
        // AudioServicesPlaySystemSound(1003) // SMS received tone (shorter)
        // AudioServicesPlaySystemSound(1025) // New mail tone

        // Also vibrate if supported
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    // Fixed port for easier discovery on simulators
    static let serverPort: UInt16 = 8888

    init() {
//        setupAppLifecycleObservers()
    }

//    private func setupAppLifecycleObservers() {
//        // Listen for app going to background
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleBackgroundTransition),
//            name: UIApplication.didEnterBackgroundNotification,
//            object: nil
//        )
//
//        // Listen for app coming to foreground
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleForegroundTransition),
//            name: UIApplication.willEnterForegroundNotification,
//            object: nil
//        )
//    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc public func handleBackgroundTransition() {
        print("📱 App backgrounded - stopping advertising")
        // Keep connections but stop advertising
        listener?.cancel()
    }

    @objc public func handleForegroundTransition() {
        print("📱 App foregrounded - restarting service")
        // Check if service is still active
        if !isAdvertising {
            print("⚠️ Service stopped while in background - restarting...")
            startAdvertising()
        } else {
            print("✅ Service still active after background")
        }
        // Refresh state to ensure UI reflects current status
        objectWillChange.send()
    }

    private func restartService() {
        print("🔄 Restarting MenuServer service...")
        startAdvertising()
    }

    func startAdvertising(serviceName: String = "MenuServer") {
        print("🎯 Starting MenuServer on port \(BonjourService.serverPort)")

        // Stop any existing service first
        stopAdvertising()

        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true

        // Allow reusing address/port
        parameters.allowLocalEndpointReuse = true

        // Allow fast reuse of port after restart
        parameters.allowFastOpen = true

        do {
            // Use fixed port for reliability on simulators
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: BonjourService.serverPort))

            listener?.service = NWListener.Service(
                name: serviceName,
                type: BonjourConstants.serviceType
            )

            listener?.stateUpdateHandler = { [weak self] state in
                Task { @MainActor [weak self] in
                    print("📡 Listener state changed: \(state)")
                    switch state {
                    case .ready:
                        self?.isAdvertising = true
                        self?.objectWillChange.send()
                        if let port = self?.listener?.port {
                            print("✅ MenuServer advertising on Bonjour (port: \(port))")
                        } else {
                            print("✅ MenuServer advertising on Bonjour")
                        }
                    case .failed(let error):
                        print("❌ Listener failed: \(error)")
                        print("❌ Error details: \(error.localizedDescription)")
                        self?.isAdvertising = false
                        self?.objectWillChange.send()
                    case .cancelled:
                        print("⏹️ Listener cancelled")
                        self?.isAdvertising = false
                        self?.objectWillChange.send()
                    case .waiting(let error):
                        print("⏳ Listener waiting: \(error)")
                    case .setup:
                        print("⚙️ Listener setup")
                    @unknown default:
                        print("🔄 Listener state: \(state)")
                        break
                    }
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                Task { @MainActor [weak self] in
                    self?.handleConnection(connection)
                }
            }

            listener?.start(queue: .main)

        } catch {
            print("❌ Failed to create listener: \(error)")
        }
    }

    func stopAdvertising() {
        listener?.cancel()
        listener = nil
        connections.forEach { $0.cancel() }
        connections.removeAll()
        isAdvertising = false
    }

    private func handleConnection(_ connection: NWConnection) {
        connections.append(connection)

        connection.stateUpdateHandler = { state in
            Task { @MainActor in
                if case .ready = state {
                    print("✅ Client connected")
                }
            }
        }

        connection.start(queue: .main)
        receiveData(from: connection)
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor [weak self] in
                if let data = data, !data.isEmpty {
                    self?.processReceivedOrder(data)
                }

                if isComplete {
                    connection.cancel()
                    self?.connections.removeAll { $0 === connection }
                } else if error == nil {
                    self?.receiveData(from: connection)
                }
            }
        }
    }

    private func processReceivedOrder(_ data: Data) {
        do {
            let orderData = try JSONDecoder().decode(OrderTransferData.self, from: data)

            let order = Order(
                roomNumber: orderData.roomNumber,
                timestamp: Date(),
                menuItems: orderData.menuItems,
                drinks: orderData.drinks.map { OrderDrink(name: $0.name, quantity: $0.quantity) },
                status: .pending
            )

            orderStore?.addOrder(order)
            print("✅ Order received from room \(orderData.roomNumber)")

            // Play notification sound for new order
            playOrderNotificationSound()

        } catch {
            print("❌ Failed to decode order: \(error)")
        }
    }
}
