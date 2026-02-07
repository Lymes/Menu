import SwiftUI

/// Supported app color schemes.
enum AppColorScheme: String, CaseIterable, Identifiable {
    case orange
    case blue
    case red

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .orange:
            return NSLocalizedString("Orange", comment: "Theme color scheme")
        case .blue:
            return NSLocalizedString("Blue", comment: "Theme color scheme")
        case .red:
            return NSLocalizedString("Red", comment: "Theme color scheme")
        }
    }
}

/// Central place for the app's look & feel.
///
/// Keep it lightweight: semantic tokens that can be reused across multiple views.
struct AppTheme: Equatable {
    let scheme: AppColorScheme

    init(_ scheme: AppColorScheme = .orange) {
        self.scheme = scheme
    }

    // MARK: - Semantic tokens

    /// Primary accent (used for `.tint`).
    var accent: Color {
        switch scheme {
        case .orange: return .orange
        case .blue: return Color(red: 0.20, green: 0.45, blue: 0.95)
        case .red: return Color(red: 0.92, green: 0.22, blue: 0.25)
        }
    }

    /// Slightly stronger accent for outlines.
    var accentStrong: Color {
        switch scheme {
        case .orange: return Color.orange.opacity(0.85)
        case .blue: return accent.opacity(0.85)
        case .red: return accent.opacity(0.88)
        }
    }

    /// Subtle selection fill used for selected cards/rows.
    var selectionFill: Color { accent.opacity(0.14) }

    /// Border color for selected items.
    var selectionStroke: Color { accentStrong }

    /// Decorative background wash.
    var backgroundWash: LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.10), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Primary button background (e.g. bottom bar primary action).
    func primaryButtonBackground(isEnabled: Bool = true, isLoading: Bool = false) -> Color {
        if isLoading { return accent.opacity(0.60) }
        return accent.opacity(isEnabled ? 0.90 : 0.35)
    }
}

// MARK: - Environment injection

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = AppTheme(.orange)
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

extension View {
    /// Inject a theme into the view hierarchy.
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}

// MARK: - Backward compatible static access (temporary)

extension AppTheme {
    /// Matches the orange tone of the app icon.
    static let orange = AppTheme(.orange).accent

    /// Subtle orange selection fill used for selected cards/rows.
    static let selectionFill = AppTheme(.orange).selectionFill

    /// Border color for selected items.
    static let selectionStroke = AppTheme(.orange).selectionStroke

    /// Decorative background wash.
    static let backgroundWash = AppTheme(.orange).backgroundWash
}
