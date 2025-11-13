import SwiftUI

/// Configuration for Gate framework, allowing apps to customize subscription behavior
public struct GateConfiguration {
    /// The app's display name (e.g., "Walnut", "Ticker")
    public let appName: String

    /// The app's brand display name for premium tier (e.g., "Walnut Pro", "Ticker Pro")
    public let premiumBrandName: String

    /// RevenueCat API key for this app (production)
    public let revenueCatAPIKey: String

    /// Premium features available in this app
    public let premiumFeatures: [PremiumFeature]

    /// Primary accent color for subscription UI
    public let accentColor: Color

    /// Gradient colors for premium branding
    public let premiumGradient: [Color]

    /// Optional app icon name for display in subscription views
    public let appIconName: String?

    /// Title shown in the confirmation screen after successful purchase
    public let confirmationTitle: String

    /// Optional message shown in the confirmation screen
    public let confirmationMessage: String?

    public init(
        appName: String,
        premiumBrandName: String,
        revenueCatAPIKey: String,
        premiumFeatures: [PremiumFeature],
        accentColor: Color = .blue,
        premiumGradient: [Color] = [.blue, .purple],
        appIconName: String? = nil,
        confirmationTitle: String? = nil,
        confirmationMessage: String? = nil
    ) {
        self.appName = appName
        self.premiumBrandName = premiumBrandName
        self.revenueCatAPIKey = revenueCatAPIKey
        self.premiumFeatures = premiumFeatures
        self.accentColor = accentColor
        self.premiumGradient = premiumGradient
        self.appIconName = appIconName
        self.confirmationTitle = confirmationTitle ?? "Welcome to \(premiumBrandName)!"
        self.confirmationMessage = confirmationMessage
    }
}

/// Represents a premium feature that can be gated
public struct PremiumFeature: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let instruction: String?
    public let icon: String

    public init(id: String, title: String, description: String, instruction: String? = nil, icon: String) {
        self.id = id
        self.title = title
        self.description = description
        self.instruction = instruction
        self.icon = icon
    }
}
