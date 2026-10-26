import Foundation

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
            fatalError("Failed to decode bundled Anurag.json profile resource")
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

/// Caller-owned strings can be localized by either app without importing its localization module.
public struct DeveloperProfileLabels: Sendable {
    public var appInformation = "App Information"
    public var version = "Version"
    public var disclaimer = "Disclaimer"
    public var social = "Let’s Connect"
    public var readMore = "Read more"
    public var showLess = "Show less"
    public var linkHint = "Opens an external link"
    public var errorTitle = "Unable to open link"
    public var errorMessage = "This link could not be opened. Please try again later."
    public var okay = "OK"
    public init() {}
}

enum SummaryText {
    static func preview(_ text: String, wordLimit: Int = 13) -> String {
        let words = text.split(whereSeparator: \.isWhitespace)
        return words.prefix(max(0, wordLimit)).joined(separator: " ") + (words.count > max(0, wordLimit) ? "…" : "")
    }
}
