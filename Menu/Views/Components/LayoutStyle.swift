import Foundation

enum LayoutStyle: String, CaseIterable, Identifiable {
    case grid = "Grid"
    case list = "List"

    var id: String { rawValue }

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "Layout style")
    }
}
