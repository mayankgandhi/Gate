import SwiftUI
import RevenueCat
import RevenueCatUI

public struct GatePaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        Group {
            if subscriptionService.isSubscribed {
                // User is already subscribed, show a simple message and dismiss
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)

                    Text("You're Already Subscribed!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Thank you for being a premium member.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            } else {
                PaywallView(displayCloseButton: true)
            }
        }
        .task {
            await subscriptionService.loadOfferings()
        }
    }
}

#Preview {
    GatePaywallView()
}
