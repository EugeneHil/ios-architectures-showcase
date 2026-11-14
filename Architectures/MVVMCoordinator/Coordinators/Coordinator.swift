import UIKit

extension MVVMCoordinator {
    /// A coordinator owns one flow: it creates screens, wires them together
    /// and decides where the user goes next.
    @MainActor
    protocol Coordinator: AnyObject {
        @discardableResult
        func start() -> UIViewController
    }
}
