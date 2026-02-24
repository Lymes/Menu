import Foundation

// Shared transfer models for client-server communication
struct OrderTransferData: Codable {
    let roomNumber: String
    let menuItems: [String]
    let drinks: [DrinkTransferData]
}

struct DrinkTransferData: Codable {
    let name: String
    let quantity: Int
}

// Bonjour service constants
struct BonjourConstants {
    static let serviceType = "_menuorder._tcp"
    static let serviceDomain = "local."
}
