import Foundation
import Network
import Combine

@MainActor
class BonjourService: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @Published var isAdvertising = false
    private var listener: NWListener?
    private var connections: [NWConnection] = []

    weak var orderStore: OrderStore?
    
    // Fixed port for easier discovery on simulators
    static let serverPort: UInt16 = 8888

    func startAdvertising(serviceName: String = "MenuServer") {
        print("🎯 Starting MenuServer on port \(BonjourService.serverPort)")
        
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        
        // Allow reusing address/port
        parameters.allowLocalEndpointReuse = true

        do {
            // Use fixed port for reliability on simulators
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: BonjourService.serverPort))

            listener?.service = NWListener.Service(
                name: serviceName,
                type: BonjourConstants.serviceType
            )

            listener?.stateUpdateHandler = { [weak self] state in
                Task { @MainActor in
                    switch state {
                    case .ready:
                        self?.isAdvertising = true
                        if let port = self?.listener?.port {
                            print("✅ MenuServer advertising on Bonjour (port: \(port))")
                        } else {
                            print("✅ MenuServer advertising on Bonjour")
                        }
                    case .failed(let error):
                        print("❌ Listener failed: \(error)")
                        self?.isAdvertising = false
                    case .cancelled:
                        print("⏹️ Listener cancelled")
                        self?.isAdvertising = false
                    case .waiting(let error):
                        print("⏳ Listener waiting: \(error)")
                    default:
                        print("🔄 Listener state: \(state)")
                        break
                    }
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                Task { @MainActor in
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
            if case .ready = state {
                print("✅ Client connected")
            }
        }

        connection.start(queue: .main)
        receiveData(from: connection)
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor in
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

        } catch {
            print("❌ Failed to decode order: \(error)")
        }
    }
}
