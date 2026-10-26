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
}
