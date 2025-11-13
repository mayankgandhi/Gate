import SwiftUI
import RevenueCatUI

public struct SubscriptionCard: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    @State private var showSubscriptionManagement = false

    private let configuration: GateConfiguration
    private let appIconImage: Image?
    private let upgradeFeaturesList: String

    public init(
        configuration: GateConfiguration,
        appIconImage: Image? = nil
    ) {
        self.configuration = configuration
        self.appIconImage = appIconImage

        // Build feature list from configuration
        let featureCount = min(3, configuration.premiumFeatures.count)
        let features = configuration.premiumFeatures.prefix(featureCount)
            .map { $0.title.lowercased() }

        if features.count > 1 {
            let allButLast = features.dropLast().joined(separator: ", ")
            let last = features.last!
            self.upgradeFeaturesList = "Unlock \(allButLast) & \(last)"
        } else if features.count == 1 {
            self.upgradeFeaturesList = "Unlock \(features[0])"
        } else {
            self.upgradeFeaturesList = "Unlock all premium features"
        }
    }

    public var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 16) {
                // Content Section
                VStack(alignment: .leading, spacing: 8) {
                    headerSection
                    subscriptionDetailsSection
                }
                .padding(16)

                Spacer()

                // Image and Action Section
                VStack(spacing: 8) {
                    if let appIconImage = appIconImage {
                        appIconImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 96, height: 96)
                    } else {
                        Image(systemName: "star.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    actionButton
                }
                .padding(.trailing, 16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background {
            premiumBackgroundGradient
        }
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showPaywall) {
            GatePaywallView()
        }
        .sheet(isPresented: $showSubscriptionManagement) {
            SubscriptionManagementView(configuration: configuration)
        }
        .task {
            await subscriptionService.checkSubscriptionStatus()
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack(spacing: 8) {
            Text(configuration.premiumBrandName)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color.white)

            if subscriptionService.isSubscribed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.green)
            }
        }
    }

    private var subscriptionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(primarySubscriptionText)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.95))
                .multilineTextAlignment(.leading)

            if subscriptionService.isSubscribed {
                if let renewalInfo = renewalDateText {
                    Text(renewalInfo)
                        .font(.system(.caption, design: .rounded, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            } else {
                Text("Transform your experience with premium features")
                    .font(.system(.caption, design: .rounded, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if subscriptionService.isSubscribed {
            Text("Manage")
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(configuration.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
        } else {
            Text("Upgrade Now")
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(configuration.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Private Methods

    private func handleTap() {
        if subscriptionService.isSubscribed {
            showSubscriptionManagement = true
        } else {
            showPaywall = true
        }
    }

    private var primarySubscriptionText: String {
        if subscriptionService.isSubscribed {
            return "All premium features active"
        } else {
            return upgradeFeaturesList
        }
    }

    private var renewalDateText: String? {
        guard subscriptionService.isSubscribed,
              let customerInfo = subscriptionService.customerInfo,
              let entitlement = customerInfo.entitlements.active.first?.value,
              let renewalDate = entitlement.expirationDate else {
            return nil
        }
        return "Renews \(renewalDate.formatted(date: .abbreviated, time: .omitted))"
    }

    private var premiumBackgroundGradient: some View {
        LinearGradient(
            colors: configuration.premiumGradient.isEmpty ? [
                Color(uiColor: UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)),
                Color(uiColor: UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1))
            ] : configuration.premiumGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
