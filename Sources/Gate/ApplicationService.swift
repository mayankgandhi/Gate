import Foundation

/// Protocol for services that need to be initialized during app startup
/// Provides a clean way to manage service lifecycle and dependencies
public protocol ApplicationService {
    /// The priority of this service's initialization (lower numbers initialize first)
    /// Use this to control initialization order when services have dependencies
    var initializationPriority: Int { get }

    /// Initialize the service
    /// This method is called during app startup in priority order
    func initialize() async throws

    /// Optional cleanup when the service is no longer needed
    /// Default implementation does nothing
    func cleanup() async
}

// MARK: - Default Implementation
public extension ApplicationService {

    var initializationPriority: Int { 100 } // Default priority

    func cleanup() async {
        // Default empty implementation
    }
}

/// Defines common initialization priorities for different types of services
public enum ServicePriority {
    /// Core services that other services depend on (e.g., User ID management)
    public static let core: Int = 0

    /// Analytics and tracking services
    public static let analytics: Int = 50

    /// Business logic services (e.g., Subscription)
    public static let business: Int = 100

    /// UI and presentation services
    public static let presentation: Int = 150

    /// Debug and development services
    public static let debug: Int = 200
}
