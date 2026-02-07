import SwiftUI

/// Central place for the app's look & feel.
/// Keep it lightweight: mostly colors that can be reused across multiple views.
enum AppTheme {
    /// Matches the orange tone of the app icon.
    static let orange = Color.orange

    /// Subtle orange selection fill used for selected cards/rows.
    static let selectionFill = Color.orange.opacity(0.14)

    /// Border color for selected items.
    static let selectionStroke = Color.orange.opacity(0.85)

    /// Decorative background wash.
    static let backgroundWash = LinearGradient(
        colors: [Color.orange.opacity(0.10), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
