import SwiftUI
import Combine

/// Persists and exposes the user's selected color scheme.
@MainActor
final class ThemeSettings: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @AppStorage("theme.scheme") private var schemeRawValue: String = AppColorScheme.orange.rawValue

    var scheme: AppColorScheme {
       get { AppColorScheme(rawValue: schemeRawValue) ?? .blue }
        set {
            schemeRawValue = newValue.rawValue
            objectWillChange.send()
        }
    }

    var theme: AppTheme { AppTheme(scheme) }
}
