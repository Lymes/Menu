import Foundation

enum LayoutStyle: String, CaseIterable, Identifiable {
    case grid = "Griglia"
    case list = "Elenco"

    var id: String { rawValue }

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "Layout style")
    }
}
