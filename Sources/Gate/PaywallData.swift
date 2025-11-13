import RevenueCat
import Foundation

public struct PaywallData {
    public let offering: Offering
    public let localization: Localization

    public init(offering: Offering, localization: Localization) {
        self.offering = offering
        self.localization = localization
    }

    public struct Localization {
        public let title: String
        public let subtitle: String
        public let callToAction: String

        public init(title: String, subtitle: String, callToAction: String) {
            self.title = title
            self.subtitle = subtitle
            self.callToAction = callToAction
        }
    }
}

public struct PaywallConfiguration {
    public let title: String
    public let subtitle: String
    public let features: [PaywallFeature]
    public let packages: [Package]
    public let termsURL: URL?
    public let privacyURL: URL?

    public init(
        title: String,
        subtitle: String,
        features: [PaywallFeature],
        packages: [Package],
        termsURL: URL?,
        privacyURL: URL?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.features = features
        self.packages = packages
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }
}

public struct PaywallFeature {
    public let title: String
    public let description: String
    public let icon: String

    public init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}
