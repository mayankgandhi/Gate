import SwiftUI
import RevenueCat
import RevenueCatUI

public struct SubscriptionGate<Content: View>: View {

    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showConfirmation = false

    let feature: PremiumFeature
    let content: (() -> Content)

    var configuration: GateConfiguration? {
        subscriptionService.configuration
    }

    public init(
        feature: PremiumFeature,
        content: @escaping (() -> Content)
    ) {
        self.feature = feature
        self.content = content
    }

    public var body: some View {
        Group {
            if subscriptionService.isPremiumFeatureAvailable(feature.id) {
                content()
            } else {
                GatePaywallView()
            }
        }
        .onChange(of: subscriptionService.shouldShowConfirmation) { _, shouldShow in
            if shouldShow {
                showConfirmation = true
            }
        }
        .overlay {
            if showConfirmation {
                SubscriptionConfirmationView(
                    title: configuration?.confirmationTitle ?? "Welcome to Premium!",
                    message: configuration?.confirmationMessage,
                    onDismiss: {
                        showConfirmation = false
                        subscriptionService.markConfirmationShown()
                    }
                )
            }
        }
    }
}

// Helper for checking subscription status in views
public struct SubscriptionStatusView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    private let configuration: GateConfiguration?

    public init(configuration: GateConfiguration? = nil) {
        self.configuration = configuration
    }

    public var body: some View {
        Group {
            if subscriptionService.isSubscribed {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(configuration?.accentColor ?? .blue)
                    Text(configuration?.premiumBrandName ?? "Premium")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            } else {
                HStack {
                    Image(systemName: "star.circle")
                        .foregroundColor(.gray)
                    Text("Free")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
    }
}
