import SwiftUI
import UIKit

/// Bridges a sample's UIKit root into the SwiftUI menu.
/// SwiftUI-based samples return a `UIHostingController` from `makeRoot`.
struct ModuleScreen: UIViewControllerRepresentable {
    let module: any ArchitectureModule.Type
    let repository: any TodoRepository

    func makeUIViewController(context: Context) -> UIViewController {
        module.makeRoot(repository: repository)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
