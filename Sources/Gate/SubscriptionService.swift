import Foundation
import RevenueCat
import Combine

public class SubscriptionService: NSObject, ObservableObject, ApplicationService {
    
    public static let shared = SubscriptionService()
    
    @Published public var isSubscribed: Bool = false
    @Published public var currentOffering: Offering?
    @Published public var customerInfo: CustomerInfo?
    @Published public var isLoading: Bool = false
    
    // State management for purchase completion and confirmation
    @Published public var purchaseJustCompleted: Bool = false
    @Published public var shouldShowConfirmation: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    var configuration: GateConfiguration?
    private var userIDProvider: (() -> String)?
    
    private override init() {
        super.init()
        // Configuration will be done in configure() method
    }
    
    /// Configure the subscription service with app-specific settings
    /// - Parameters:
    ///   - configuration: The Gate configuration for this app
    ///   - userIDProvider: Optional closure to provide the current user ID for RevenueCat
    public func configure(
        configuration: GateConfiguration,
        userIDProvider: (() -> String)? = nil
    ) {
        self.configuration = configuration
        self.userIDProvider = userIDProvider
    }
    
    // MARK: - ApplicationService Conformance
    
    public var initializationPriority: Int { ServicePriority.business }
    
    public func initialize() async throws {
        guard let configuration = configuration else {
            throw GateError.notConfigured
        }
        
        // Determine which API key to use
        let apiKey: String
        
        apiKey = configuration.revenueCatAPIKey
        
        // Configure RevenueCat
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: apiKey)
        
        // Set up delegate
        Purchases.shared.delegate = self
        
        // Login with user ID if provider is available
        if let userIDProvider = userIDProvider {
            let userID = userIDProvider()
            _ = try? await Purchases.shared.logIn(userID)
        }
        
        // Check initial subscription status
        await checkSubscriptionStatus()
        
        // Defer loading offerings - will be loaded lazily when needed (e.g., when showing paywall)
        // This reduces app launch time significantly
    }
    
    // MARK: - Subscription Status
    
    public func checkSubscriptionStatus() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await update(customerInfo: customerInfo)
        } catch {
            print("Failed to fetch customer info: \(error)")
            await MainActor.run {
                self.isSubscribed = false
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    @MainActor
    public func update(customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        self.isSubscribed = customerInfo.entitlements.active.count > 0
    }
    
    // MARK: - Server-Driven Paywalls
    
    public func loadOfferings() async {
        // Skip if already loaded
        guard currentOffering == nil else { return }
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            await MainActor.run {
                self.currentOffering = offerings.current
            }
        } catch {
            print("Failed to load offerings: \(error)")
        }
    }
    
    // MARK: - RevenueCat Paywall Integration
    
    public func loadPaywall() async -> PaywallData? {
        guard let configuration = configuration else { return nil }
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Get the current offering
            guard let offering = offerings.current else {
                print("No current offering found")
                return nil
            }
            
            // RevenueCat paywall data is available through the offering's metadata
            return PaywallData(
                offering: offering,
                localization: PaywallData.Localization(
                    title: offering.metadata["title"] as? String ?? "Unlock Premium Features",
                    subtitle: offering.metadata["subtitle"] as? String ?? "Get access to all \(configuration.premiumBrandName) features",
                    callToAction: offering.metadata["cta"] as? String ?? "Subscribe Now"
                )
            )
        } catch {
            print("Failed to load paywall: \(error)")
            return nil
        }
    }
    
    // MARK: - Purchase Management
    
    public func purchase(package: Package) async throws -> CustomerInfo {
        let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
        await MainActor.run {
            self.customerInfo = customerInfo
            self.isSubscribed = customerInfo.entitlements.active.count > 0
            
            // Set flags for purchase completion and confirmation display
            self.purchaseJustCompleted = true
            self.shouldShowConfirmation = true
        }
        return customerInfo
    }
    
    public func restorePurchases() async throws -> CustomerInfo {
        let customerInfo = try await Purchases.shared.restorePurchases()
        await MainActor.run {
            self.customerInfo = customerInfo
            self.isSubscribed = customerInfo.entitlements.active.count > 0
        }
        return customerInfo
    }
    
    /// Mark that the confirmation screen has been shown
    /// Resets the purchase completion and confirmation flags
    @MainActor
    public func markConfirmationShown() {
        purchaseJustCompleted = false
        shouldShowConfirmation = false
    }
    
    // MARK: - Entitlement Checking
    
    public func hasEntitlement(_ entitlementIdentifier: String) -> Bool {
        guard let customerInfo = customerInfo else { return false }
        return customerInfo.entitlements[entitlementIdentifier]?.isActive == true
    }
    
    public func isPremiumFeatureAvailable(_ featureId: String? = nil) -> Bool {
        // If a specific feature is requested, check if user has it
        // For now, we just check if they have any active entitlements
        return hasEntitlement("pro") || isSubscribed
    }
    
    public func getPaywallConfiguration() async -> PaywallConfiguration? {
        guard let configuration = configuration else { return nil }
        
        // Load offerings lazily if not already loaded
        await loadOfferings()
        
        guard let offering = currentOffering else { return nil }
        
        // Convert PremiumFeature to PaywallFeature
        let features = configuration.premiumFeatures.map { feature in
            PaywallFeature(
                title: feature.title,
                description: feature.description,
                icon: feature.icon
            )
        }
        
        return PaywallConfiguration(
            title: "Unlock Full Access",
            subtitle: "Get unlimited access to all \(configuration.premiumBrandName) features",
            features: features,
            packages: Array(offering.availablePackages),
            termsURL: URL(string: "https://\(configuration.appName.lowercased()).app/terms"),
            privacyURL: URL(string: "https://\(configuration.appName.lowercased()).app/privacy")
        )
    }
    
    public func login(userId: String) async {
        _ = try? await Purchases.shared.logIn(userId)
    }
    
    public func logout() async {
        _ = try? await Purchases.shared.logOut()
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionService: @MainActor PurchasesDelegate {
    public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let wasSubscribed = self.isSubscribed
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.isSubscribed = customerInfo.entitlements.active.count > 0
        }
        
        // Detect new subscription (transition from not subscribed to subscribed)
        if !wasSubscribed && self.isSubscribed {
            Task { @MainActor in
                self.shouldShowConfirmation = true
            }
        }
    }
}

// MARK: - Errors

public enum GateError: Error, LocalizedError {
    case notConfigured
    
    public var errorDescription: String? {
        switch self {
            case .notConfigured:
                return "Gate framework is not configured. Call configure() before initialize()."
        }
    }
}
