# Gate

A SwiftUI framework for managing subscription paywalls and premium features with RevenueCat integration.

## Features

- 🔒 Easy subscription gating for premium features
- 💳 Built-in paywall UI with RevenueCat integration
- ✨ Customizable configuration for different apps
- 📱 Cross-platform support (iOS, macOS)
- 🎨 Customizable colors and branding
- ✅ Subscription confirmation views

## Installation

### Swift Package Manager

Add Gate to your project through Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/mayankgandhi/Gate.git`
3. Select the version or branch you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mayankgandhi/Gate.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: ["Gate"]
    )
]
```

## Usage

### 1. Configure Gate

Configure Gate in your app's initialization (e.g., in your `App` struct or AppDelegate):

```swift
import Gate

@main
struct YourApp: App {
    init() {
        // Configure Gate with your app settings
        SubscriptionService.shared.configure(
            configuration: GateConfiguration(
                appName: "YourApp",
                premiumBrandName: "YourApp Pro",
                revenueCatAPIKey: "your_revenuecat_api_key",
                premiumFeatures: [
                    PremiumFeature(
                        id: "feature_1",
                        title: "Advanced Analytics",
                        description: "Get detailed insights",
                        icon: "chart.bar.fill"
                    ),
                    PremiumFeature(
                        id: "feature_2",
                        title: "Cloud Sync",
                        description: "Sync across all devices",
                        icon: "icloud.fill"
                    )
                ],
                accentColor: .blue,
                premiumGradient: [.blue, .purple]
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Gate Premium Features

Use `SubscriptionGate` to protect premium content:

```swift
import Gate
import SwiftUI

struct ContentView: View {
    var body: some View {
        SubscriptionGate(
            feature: PremiumFeature(
                id: "advanced_features",
                title: "Advanced Features",
                description: "Unlock powerful tools",
                icon: "star.fill"
            )
        ) {
            // Your premium content here
            PremiumContentView()
        }
    }
}
```

### 3. Show Subscription Status

Display the user's subscription status:

```swift
import Gate
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            SubscriptionStatusView()
            // ... other profile content
        }
    }
}
```

### 4. Manage Subscriptions

Show the subscription management view:

```swift
import Gate
import SwiftUI

struct SettingsView: View {
    @State private var showSubscriptionManagement = false

    var body: some View {
        Button("Manage Subscription") {
            showSubscriptionManagement = true
        }
        .sheet(isPresented: $showSubscriptionManagement) {
            SubscriptionManagementView()
        }
    }
}
```

## Configuration Options

### GateConfiguration

- `appName`: Your app's display name
- `premiumBrandName`: Your premium tier branding (e.g., "App Pro")
- `revenueCatAPIKey`: Your RevenueCat API key
- `premiumFeatures`: Array of premium features to showcase
- `accentColor`: Primary color for UI elements
- `premiumGradient`: Gradient colors for premium branding
- `appIconName`: Optional app icon to display
- `confirmationTitle`: Title for post-purchase confirmation
- `confirmationMessage`: Optional message for confirmation screen

### PremiumFeature

- `id`: Unique identifier for the feature
- `title`: Display title
- `description`: Feature description
- `instruction`: Optional usage instructions
- `icon`: SF Symbol name for the icon

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- RevenueCat account with configured products

## License

[Add your license here]

## Support

For issues and feature requests, please open an issue on GitHub.
