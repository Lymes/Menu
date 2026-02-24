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

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        browser = NWBrowser(for: .bonjour(type: BonjourConstants.serviceType, domain: BonjourConstants.serviceDomain), using: parameters)

        browser?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    print("✅ Browser ready, discovering servers...")
                case .failed(let error):
                    print("❌ Browser failed: \(error)")
                case .waiting(let error):
                    print("⏳ Browser waiting: \(error)")
                default:
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
        guard let server = selectedServer else {
            print("❌ No server selected - still discovering...")
            completion(false)
            return
        }
        
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
        
        print("📤 Sending order to server: \(server.endpoint)")
        connectAndSend(to: server.endpoint, data: jsonData, completion: completion)
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
}
