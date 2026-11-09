import Foundation
import LocalizationKit

public struct DeveloperLink: Identifiable, Decodable, Sendable {
    public let title: String
    public let icon: String
    public let url: URL
    public var id: String { url.absoluteString }
    public init(title: String, icon: String, url: URL) {
        self.title = title; self.icon = icon; self.url = url
    }
    public var canOpen: Bool {
        switch url.scheme?.lowercased() {
        case "https": return url.host?.isEmpty == false
        case "mailto": return !url.path.isEmpty
        default: return false
        }
    }
}

public struct DeveloperProfile: Decodable, Sendable {
    public let name: String
    public let role: String
    public let summary: String
    public let portrait: String
    public let links: [DeveloperLink]
    public init(name: String, role: String, summary: String, portrait: String = "Anurag", links: [DeveloperLink]) {
        self.name = name; self.role = role; self.summary = summary
        self.portrait = portrait; self.links = links
    }
    /// The extracted profile and artwork are owned by this private package.
    static let resourceBundle = Bundle.module
    public static let anurag: DeveloperProfile = {
        // A required, immutable package resource, validated by the package tests.
        guard let url = Bundle.module.url(forResource: "Anurag", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let profile = try? JSONDecoder().decode(DeveloperProfile.self, from: data) else {
            #if DEBUG
            fatalError("Failed to decode bundled Anurag.json profile resource")
            #else
            return DeveloperProfile(name: "", role: "", summary: "", portrait: "", links: [])
            #endif
        }
        return profile
    }()
}

public struct DeveloperAppInfo: Sendable {
    public let name: String
    public let version: String
    public let build: String
    public let disclaimer: String
    public init(name: String, version: String, build: String, disclaimer: String) {
        self.name = name; self.version = version; self.build = build; self.disclaimer = disclaimer
    }
}

/// Caller-owned strings resolved from the canonical `LocalizationKit` catalog (`profile.*`).
/// Standalone callers that omit `resolve` receive localized values from `LocalizationKit`.
public struct DeveloperProfileLabels: Sendable, Equatable {
    public var appInformation: String
    public var version: String
    public var disclaimer: String
    public var social: String
    public var readMore: String
    public var showLess: String
    public var linkHint: String
    public var errorTitle: String
    public var errorMessage: String
    public var okay: String

    public init(
        appInformation: String,
        version: String,
        disclaimer: String,
        social: String,
        readMore: String,
        showLess: String,
        linkHint: String,
        errorTitle: String,
        errorMessage: String,
        okay: String
    ) {
        self.appInformation = appInformation
        self.version = version
        self.disclaimer = disclaimer
        self.social = social
        self.readMore = readMore
        self.showLess = showLess
        self.linkHint = linkHint
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
        self.okay = okay
    }

    /// Initializes labels by querying the provided `LocalizationProviding` instance (defaults to `LocalizationController.shared`).
    public init(provider: any LocalizationProviding = LocalizationController.shared) {
        self.init(
            appInformation: provider.string("profile.app_information"),
            version: provider.string("profile.version"),
            disclaimer: provider.string("profile.disclaimer"),
            social: provider.string("profile.social"),
            readMore: provider.string("profile.read_more"),
            showLess: provider.string("profile.show_less"),
            linkHint: provider.string("profile.link_hint"),
            errorTitle: provider.string("profile.error_title"),
            errorMessage: provider.string("profile.error_message"),
            okay: provider.string("profile.okay")
        )
    }

    /// Initializes labels directly from a `LocalizedContext`.
    public init<Domain: LocalizationDomain>(context: LocalizedContext<Domain>) {
        self.init(provider: context.provider)
    }

    /// Initializes labels directly from `CommonStrings`.
    public init(context: CommonStrings) {
        self.init(provider: context.provider)
    }

    /// Initializes labels using a custom key resolution closure.
    public init(resolving resolve: (String) -> String) {
        self.init(
            appInformation: resolve("profile.app_information"),
            version: resolve("profile.version"),
            disclaimer: resolve("profile.disclaimer"),
            social: resolve("profile.social"),
            readMore: resolve("profile.read_more"),
            showLess: resolve("profile.show_less"),
            linkHint: resolve("profile.link_hint"),
            errorTitle: resolve("profile.error_title"),
            errorMessage: resolve("profile.error_message"),
            okay: resolve("profile.okay")
        )
    }

    /// Deterministic key identifiers for standalone testing or unlocalized catalogs.
    public static let keys = DeveloperProfileLabels(resolving: { $0 })
}

enum SummaryText {
    static func preview(_ text: String, wordLimit: Int = 13) -> String {
        let words = text.split(whereSeparator: \.isWhitespace)
        return words.prefix(max(0, wordLimit)).joined(separator: " ") + (words.count > max(0, wordLimit) ? "…" : "")
    }
}

#if DEBUG
/// Diagnostics and developer controls available in debug configurations.
public struct DeveloperDiagnostics: Sendable {
    public enum Environment: String, CaseIterable, Sendable {
        case production
        case staging
        case localMock
    }

    public static let shared = DeveloperDiagnostics()

    public init() {}
}
#endif
