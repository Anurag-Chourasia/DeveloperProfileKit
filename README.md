# DeveloperProfileKit

Private Swift package for Anurag Chourasia's “Know Your Developer” screen in MyTV and ShowBook. Repository access is required to resolve it. This is not a public SDK.

The package owns the portrait, social artwork, profile biography, expandable typing summary, app-information/disclaimer sections and list/grid social links. Apps own navigation, connectivity, appearance controls and app-specific metadata. UI uses DesignTokensKit 1.2.0 and UIComponentsKit 1.2.0, pinned exactly.

```swift
import DeveloperProfileKit

DeveloperProfileView(app: DeveloperAppInfo(
    name: "ShowBook",
    version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—",
    build: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—",
    disclaimer: "Book metadata and covers are provided by Open Library."
))
.navigationTitle("Know Your Developer")
```

`DeveloperProfile` and `DeveloperProfileLabels` let authorized apps supply alternate copy. Portrait and social icon names refer to the bundled assets (Anurag, GitHub, LinkedIn, Gmail, CV). The default profile preserves MyTV's existing contact destinations. `DeveloperAppInfo` always comes from the host, so this module never reports its own bundle version as the app version.

`layout` accepts CatalogLayout; accessibility sizes resolve grid to list. Full biography is immediately available with VoiceOver or Reduce Motion. Otherwise expansion types words using a view-scoped cancellable task. Supported external destinations are HTTPS and mailto; unsuccessful opens show an alert. The package makes no network requests itself.

Supported: iOS 16.6+, macOS 14+, Swift 6.0+. CI validates strict-concurrency host tests and the iOS Simulator product. Run `swift test` with the selected Xcode toolchain. When Desktop filesystem metadata interferes with signing, use `--scratch-path /tmp/developer-profile-build`.

Consumers must pin a released version and verified SHA. Both app workflows use separate read-only deploy keys; no credentials belong in this repository. Proprietary source and artwork: all rights reserved, no redistribution or third-party integration license granted.
