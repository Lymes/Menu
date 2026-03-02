import Foundation
import Network
import Combine

@MainActor
class OrderSenderService: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @Published var isConnected = false
    @Published var discoveredServers: [NWBrowser.Result] = []
    @Published var selectedServer: NWBrowser.Result?

    private var browser: NWBrowser?
    private var connection: NWConnection?

    func startDiscovery() {
        print("🔍 Starting Bonjour discovery for \(BonjourConstants.serviceType).\(BonjourConstants.serviceDomain)")

        // Stop any existing browser first
        stopDiscovery()

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Allow reusing discovery
        parameters.allowLocalEndpointReuse = true

        browser = NWBrowser(for: .bonjour(type: BonjourConstants.serviceType, domain: BonjourConstants.serviceDomain), using: parameters)

        browser?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                print("📡 Browser state changed: \(state)")
                switch state {
                case .ready:
                    print("✅ Browser ready, discovering servers...")
                case .failed(let error):
                    print("❌ Browser failed: \(error)")
                    print("❌ Error code: \(error.debugDescription)")

                    // Common error codes and solutions
                    if error.debugDescription.contains("-65555") || error.debugDescription.contains("NoAuth") {
                        print("�🚨 LOCAL NETWORK PERMISSION DENIED!")
                        print("💡 Solution 1: Go to iOS Settings → Privacy & Security → Local Network → Enable for this app")
                        print("💡 Solution 2: Delete and reinstall the app to trigger permission dialog")
                        print("💡 Solution 3: On simulator, try 'Device → Erase All Content and Settings' then reinstall")

                        // Try alternative discovery after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            print("🔄 Attempting fallback discovery...")
                            self?.tryFallbackDiscovery()
                        }
                    }

                case .cancelled:
                    print("⏹️ Browser cancelled")
                case .waiting(let error):
                    print("⏳ Browser waiting: \(error)")
                case .setup:
                    print("⚙️ Browser setup")
                @unknown default:
                    print("🔄 Browser state: \(state)")
                    break
                }
            }
        }

        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            Task { @MainActor in
                self?.discoveredServers = Array(results)

                print("📡 Discovered \(results.count) server(s):")
                for result in results {
                    print("  - \(result.endpoint)")
                }

                // Auto-select first server if none selected
                if self?.selectedServer == nil, let first = results.first {
                    self?.selectedServer = first
                    print("✅ Auto-selected server: \(first.endpoint)")
                }
            }
        }

        browser?.start(queue: .main)
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
    }

    func sendOrder(roomNumber: String, menuItems: [String], drinks: [(name: String, quantity: Int)], completion: @escaping (Bool) -> Void) {
        let orderData = OrderTransferData(
            roomNumber: roomNumber,
            menuItems: menuItems,
            drinks: drinks.map { DrinkTransferData(name: $0.name, quantity: $0.quantity) }
        )

        guard let jsonData = try? JSONEncoder().encode(orderData) else {
            print("❌ Failed to encode order")
            completion(false)
            return
        }

        // Check if we have a server or fallback connection
        if let server = selectedServer {
            print("📤 Sending order to server: \(server.endpoint)")
            connectAndSend(to: server.endpoint, data: jsonData, completion: completion)
        } else if let existingConnection = connection, isConnected {
            print("📤 Sending order via fallback connection")
            sendData(connection: existingConnection, data: jsonData, completion: completion)
        } else {
            // Try direct connection to localhost as last resort
            print("📤 No server found, trying direct localhost connection...")
            let fallbackEndpoint = NWEndpoint.hostPort(host: "172.16.55.100", port: NWEndpoint.Port(integerLiteral: 8888))
            connectAndSend(to: fallbackEndpoint, data: jsonData, completion: completion)
        }
    }

    private func connectAndSend(to endpoint: NWEndpoint, data: Data, completion: @escaping (Bool) -> Void) {
        let connection = NWConnection(to: endpoint, using: .tcp)

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.sendData(connection: connection, data: data, completion: completion)
                case .failed(let error):
                    print("❌ Connection failed: \(error)")
                    self?.isConnected = false
                    completion(false)
                case .cancelled:
                    self?.isConnected = false
                default:
                    break
                }
            }
        }

        connection.start(queue: .main)
        self.connection = connection
    }

    private func sendData(connection: NWConnection, data: Data, completion: @escaping (Bool) -> Void) {
        connection.send(content: data, completion: .contentProcessed { error in
            Task { @MainActor in
                if let error = error {
                    print("❌ Send failed: \(error)")
                    completion(false)
                } else {
                    print("✅ Order sent successfully")
                    completion(true)
                }

                connection.cancel()
                self.connection = nil
                self.isConnected = false
            }
        })
    }

    private func tryFallbackDiscovery() {
        print("🔄 Trying fallback discovery mechanism...")

        // Try direct connection to known port
        let fallbackEndpoint = NWEndpoint.hostPort(host: "172.16.55.100", port: NWEndpoint.Port(integerLiteral: 8888))
        let testConnection = NWConnection(to: fallbackEndpoint, using: .tcp)

        testConnection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    print("✅ Fallback: Found server on 172.16.55.100:8888")

                    // Create a fallback endpoint and add to discovered servers
                    self?.discoveredServers = []
                    self?.selectedServer = nil

                    // Set the fallback endpoint directly
                    if let self = self {
                        // Use a direct endpoint connection instead of Bonjour result
                        self.connection = testConnection
                        self.isConnected = true

                        print("✅ Using direct connection to MenuServer")
                        // Don't cancel - keep this connection for sending orders
                    }

                case .failed:
                    print("❌ Fallback failed - server not running on localhost:8888")
                    testConnection.cancel()
                default:
                    break
                }
            }
        }

        testConnection.start(queue: .main)

        // Cancel test connection after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            testConnection.cancel()
        }
    }
}
