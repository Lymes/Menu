import Foundation

struct MenuItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let imageName: String
}
