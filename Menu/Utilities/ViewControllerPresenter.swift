import SwiftUI
import UIKit

/// A tiny bridge to expose a stable UIViewController that lives inside the SwiftUI hierarchy.
///
/// Use it as an invisible background view and capture the controller in a closure.
struct ViewControllerPresenter: UIViewControllerRepresentable {
    let onResolve: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ResolverViewController(onResolve: onResolve)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Intentionally no-op
    }

    private final class ResolverViewController: UIViewController {
        private let onResolve: (UIViewController) -> Void
        private var didResolve = false

        init(onResolve: @escaping (UIViewController) -> Void) {
            self.onResolve = onResolve
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            resolveIfNeeded()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            resolveIfNeeded()
        }

        private func resolveIfNeeded() {
            guard !didResolve else { return }
            didResolve = true
            onResolve(self)
        }
    }
}
