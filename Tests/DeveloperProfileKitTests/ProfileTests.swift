import XCTest
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
    func testProfileLabelsResolveViaInjectedClosureAndStandaloneFallback() {
        let standalone = DeveloperProfileLabels()
        XCTAssertEqual(standalone.appInformation, "profile.app_information")
        XCTAssertEqual(standalone.version, "profile.version")
        XCTAssertEqual(standalone.disclaimer, "profile.disclaimer")
        XCTAssertEqual(standalone.social, "profile.social")
        XCTAssertEqual(standalone.readMore, "profile.read_more")
        XCTAssertEqual(standalone.showLess, "profile.show_less")
        XCTAssertEqual(standalone.linkHint, "profile.link_hint")
        XCTAssertEqual(standalone.errorTitle, "profile.error_title")
        XCTAssertEqual(standalone.errorMessage, "profile.error_message")
        XCTAssertEqual(standalone.okay, "profile.okay")

        let resolved = DeveloperProfileLabels { key in "[\(key)]" }
        XCTAssertEqual(resolved.appInformation, "[profile.app_information]")
        XCTAssertEqual(resolved.okay, "[profile.okay]")
    }
}
