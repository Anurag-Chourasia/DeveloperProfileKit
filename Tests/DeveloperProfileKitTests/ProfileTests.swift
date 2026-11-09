import XCTest
import SwiftUI
import LocalizationKit
import FoundationKit
#if canImport(AppKit)
import AppKit
#endif
@testable import DeveloperProfileKit

final class ProfileTests: XCTestCase {
    func testBundledProfileAndLinks() {
        let profile = DeveloperProfile.anurag
        XCTAssertEqual(profile.name, "Anurag Chourasia")
        XCTAssertFalse(profile.summary.isEmpty)
        XCTAssertEqual(profile.links.count, 4)
        XCTAssertEqual(Set(profile.links.map(\.id)).count, 4)
        XCTAssertTrue(profile.links.allSatisfy(\.canOpen))
        XCTAssertEqual(profile.links.first(where: { $0.title == "Email" })?.url.absoluteString, "mailto:anuragchourasiaios@gmail.com")
    }
    #if canImport(AppKit)
    func testAllBundledArtworkLoads() {
        let profile = DeveloperProfile.anurag
        for name in [profile.portrait] + profile.links.map(\.icon) {
            XCTAssertNotNil(DeveloperProfile.resourceBundle.image(forResource: name), name)
        }
    }
    #endif

    func testUnsafeLinkSchemesAreRejected() throws {
        for value in ["file:///tmp/private", "javascript:alert(1)", "http://example.com", "relative"] {
            let url = try XCTUnwrap(URL(string: value))
            XCTAssertFalse(DeveloperLink(title: "Link", icon: "", url: url).canOpen)
        }
    }
    func testPreviewHandlesWhitespaceAndShortText() {
        XCTAssertEqual(SummaryText.preview("one\n two   three", wordLimit: 2), "one two…")
        XCTAssertEqual(SummaryText.preview("one two", wordLimit: 2), "one two")
        XCTAssertEqual(SummaryText.preview(""), "")
    }
    func testAppMetadataIsCallerOwned() {
        let app = DeveloperAppInfo(name: "ShowBook", version: "2.0", build: "42", disclaimer: "Book metadata")
        XCTAssertEqual(app.name, "ShowBook")
        XCTAssertEqual(app.version, "2.0")
        XCTAssertEqual(app.build, "42")
        XCTAssertEqual(app.disclaimer, "Book metadata")
    }
    func testProfileLabelsResolveViaLocalizationKitAndCustomResolution() {
        let localized = DeveloperProfileLabels()
        XCTAssertEqual(localized.appInformation, "App Information")
        XCTAssertEqual(localized.version, "Version")
        XCTAssertEqual(localized.disclaimer, "Disclaimer")
        XCTAssertEqual(localized.social, "Let’s Connect")
        XCTAssertEqual(localized.readMore, "Read more")
        XCTAssertEqual(localized.showLess, "Show less")
        XCTAssertEqual(localized.linkHint, "Opens an external link")
        XCTAssertEqual(localized.errorTitle, "Unable to open link")
        XCTAssertEqual(localized.errorMessage, "This link could not be opened. Please try again later.")
        XCTAssertEqual(localized.okay, "OK")

        let keys = DeveloperProfileLabels.keys
        XCTAssertEqual(keys.appInformation, "profile.app_information")
        XCTAssertEqual(keys.version, "profile.version")
        XCTAssertEqual(keys.disclaimer, "profile.disclaimer")
        XCTAssertEqual(keys.social, "profile.social")
        XCTAssertEqual(keys.readMore, "profile.read_more")
        XCTAssertEqual(keys.showLess, "profile.show_less")
        XCTAssertEqual(keys.linkHint, "profile.link_hint")
        XCTAssertEqual(keys.errorTitle, "profile.error_title")
        XCTAssertEqual(keys.errorMessage, "profile.error_message")
        XCTAssertEqual(keys.okay, "profile.okay")

        let resolved = DeveloperProfileLabels { key in "[\(key)]" }
        XCTAssertEqual(resolved.appInformation, "[profile.app_information]")
        XCTAssertEqual(resolved.okay, "[profile.okay]")

        let contextLabels = DeveloperProfileLabels(context: CommonStrings.shared)
        XCTAssertEqual(contextLabels.appInformation, "App Information")
        XCTAssertEqual(contextLabels.okay, "OK")
    }

    @MainActor
    func testDeveloperProfileViewInitializes() {
        let app = DeveloperAppInfo(name: "ShowBook", version: "2.0", build: "42", disclaimer: "Book metadata")
        let viewDefault = DeveloperProfileView(app: app)
        XCTAssertNotNil(viewDefault.body)

        let customLabels = DeveloperProfileLabels(resolving: { "[\($0)]" })
        let viewCustom = DeveloperProfileView(app: app, layout: .grid, labels: customLabels, clock: ContinuousClock())
        XCTAssertNotNil(viewCustom.body)

        let viewWithAppClock = DeveloperProfileView(app: app, appClock: SystemClock())
        XCTAssertNotNil(viewWithAppClock.body)
    }

    func testDeveloperProfileCustomInit() throws {
        let siteURL = try XCTUnwrap(URL(string: "https://example.com"))
        let profile = DeveloperProfile(
            name: "Test Developer",
            role: "iOS Engineer",
            summary: "Building apps",
            portrait: "test_portrait",
            links: [
                DeveloperLink(title: "Site", icon: "globe", url: siteURL)
            ]
        )
        XCTAssertEqual(profile.name, "Test Developer")
        XCTAssertEqual(profile.role, "iOS Engineer")
        XCTAssertEqual(profile.summary, "Building apps")
        XCTAssertEqual(profile.portrait, "test_portrait")
        XCTAssertEqual(profile.links.count, 1)
        XCTAssertEqual(profile.links.first?.title, "Site")
    }

    #if DEBUG
    func testDeveloperDiagnostics() {
        XCTAssertEqual(DeveloperDiagnostics.Environment.allCases.count, 3)
        XCTAssertEqual(DeveloperDiagnostics.Environment.production.rawValue, "production")
        XCTAssertEqual(DeveloperDiagnostics.Environment.staging.rawValue, "staging")
        XCTAssertEqual(DeveloperDiagnostics.Environment.localMock.rawValue, "localMock")

        let diag = DeveloperDiagnostics()
        XCTAssertNotNil(diag)
        XCTAssertNotNil(DeveloperDiagnostics.shared)
    }
    #endif
}
