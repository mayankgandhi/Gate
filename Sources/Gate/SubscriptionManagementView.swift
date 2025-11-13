import SwiftUI

public struct SubscriptionManagementView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    private let configuration: GateConfiguration

    public init(configuration: GateConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    subscriptionStatusCard
                    subscriptionDetailsCard
                    subscriptionActionsCard
                }
                .padding(16)
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await subscriptionService.checkSubscriptionStatus()
        }
    }

    // MARK: - View Components

    private var subscriptionStatusCard: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(configuration.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.premiumBrandName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Premium Active")
                            .font(.subheadline)
                            .foregroundStyle(Color.green)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.green)
                }

                if let customerInfo = subscriptionService.customerInfo,
                   let entitlement = customerInfo.entitlements.active.first?.value {

                    Divider()

                    VStack(spacing: 12) {
                        subscriptionDetailRow(
                            title: "Plan",
                            value: entitlement.productIdentifier
                        )

                        if let renewalDate = entitlement.expirationDate {
                            subscriptionDetailRow(
                                title: "Renews",
                                value: renewalDate.formatted(date: .abbreviated, time: .omitted)
                            )
                        }

                        if let purchaseDate = entitlement.latestPurchaseDate {
                            subscriptionDetailRow(
                                title: "Purchased",
                                value: purchaseDate.formatted(date: .abbreviated, time: .omitted)
                            )
                        }
                    }
                }
            }
        }
    }

    private var subscriptionDetailsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Premium Features")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    ForEach(configuration.premiumFeatures) { feature in
                        featureRow(
                            icon: feature.icon,
                            title: feature.title,
                            description: feature.description
                        )
                    }
                }
            }
        }
    }

    private var subscriptionActionsCard: some View {
        CardView {
            VStack(spacing: 16) {
                Text("Manage Subscription")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Button(action: manageSubscriptionInAppStore) {
                        Text("Manage in App Store")
                            .font(.headline)
                            .foregroundColor(configuration.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    Button(action: { Task { await restorePurchases() } }) {
                        Text("Restore Purchases")
                            .font(.headline)
                            .foregroundColor(configuration.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }

                Text("Changes to your subscription are managed through the App Store. Use the button above to modify or cancel your subscription.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helper Views

    private func subscriptionDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(configuration.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private func manageSubscriptionInAppStore() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }

    private func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await subscriptionService.restorePurchases()
        } catch {
            // Handle error - could show an alert here
            print("Failed to restore purchases: \(error)")
        }
    }
}

// MARK: - Card View Helper

private struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}
