import Foundation

struct DrinkItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let imageName: String
    var quantity: Int = 0
}
