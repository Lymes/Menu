import Foundation
import SwiftData

@Model
class Order {
    var id: UUID
    var roomNumber: String
    var timestamp: Date
    var menuItems: [String] // titles of selected menu items
    var drinks: [OrderDrink]
    var status: OrderStatus
    
    init(id: UUID = UUID(), 
         roomNumber: String, 
         timestamp: Date = Date(),
         menuItems: [String],
         drinks: [OrderDrink],
         status: OrderStatus = .pending) {
        self.id = id
        self.roomNumber = roomNumber
        self.timestamp = timestamp
        self.menuItems = menuItems
        self.drinks = drinks
        self.status = status
    }
}

struct OrderDrink: Codable, Hashable {
    let name: String
    let quantity: Int
}

enum OrderStatus: String, Codable {
    case pending
    case preparing
    case completed
    case cancelled
}
