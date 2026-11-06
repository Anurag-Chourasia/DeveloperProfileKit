# DeveloperProfileKit

A dedicated, accessible Swift package encapsulating Anurag Chourasia's "Know Your Developer" profile, credits, and portfolio experience for multi-app architectures.

![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B%20%7C%20macOS%2014.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange)
![Toolchain](https://img.shields.io/badge/Xcode-27.1-purple)
![CI](https://img.shields.io/badge/CI-Passing-brightgreen)
![SwiftLint](https://img.shields.io/badge/SwiftLint-0.65.1%20Strict-green)
![Version](https://img.shields.io/badge/Release-v1.2.0-blueviolet)
![Dependencies](https://img.shields.io/badge/Dependencies-DesignTokensKit%20%7C%20UIComponentsKit%20%7C%20LocalizationKit-blueviolet)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 1. Executive Summary & Purpose

`DeveloperProfileKit` provides a reusable, accessible developer bio and credits screen across **ShowBook**, **myTV**, and **Motivation Daily**. It standardizes author attribution, verified outbound professional links, and app metadata display while remaining cleanly decoupled from host domain models.

### Key Engineering Objectives:
- **Zero-Network Profile Bundling**: Encapsulates portrait artwork, social icons, and structured developer biography (`Anurag.json`) inside the package bundle, eliminating network dependencies.
- **Injected Host Metadata (`DeveloperAppInfo`)**: The host application injects app-specific branding, marketing version, build number, and legal disclaimers.
- **Injected Localization (`DeveloperProfileLabels`) (IOS-59)**: Screen titles, section headers, and outbound link descriptions are localized via caller injection, preventing rigid bundle coupling.
- **VoiceOver & Motion Accessibility**: Respects `accessibilityReduceMotion` by bypassing typing animations, and outlines explicit VoiceOver navigation ordering.

---

## 2. Architecture & Design Principles

```mermaid
flowchart TD
    Host["Host Application (ShowBook / myTV / Motivation Daily)"] -->|Injects AppInfo & Localized Labels| View["DeveloperProfileView"]
    View --> BundleData["Bundled Resources (Anurag.json, Portrait, Icons)"]
    View --> Tokens["DesignTokensKit (Spacing, Typography, Metrics)"]
    View --> Components["UIComponentsKit (SurfaceCard, Buttons)"]
    View --> Localisation["LocalisationKit (Injected Labels)"]
    View --> Accessibility["VoiceOver & Motion Engine"]
    View --> Outbound["Validated Outbound Links (GitHub, LinkedIn, Email, Resume)"]
```

### Architectural Tenets:
1. **Host App Decoupling**: Contains no business logic or API endpoints of the host applications; strictly renders developer attribution.
2. **Swift 6 Concurrency Compliance**: All models (`DeveloperProfile`, `DeveloperAppInfo`, `DeveloperProfileLabels`) conform to `Sendable`.
3. **Safe Outbound Dispatching**: Validates and sanitizes outbound HTTPS/mailto URLs before handing off to iOS `openURL`.

---

## 3. Dependency Graph & Consumer Matrix

| Direction | Package / Project | Responsibility |
|---|---|---|
| **Upstream Dependencies** | **DesignTokensKit** (`v1.22.3`) | Spacing, corner radius, touch targets, and typography tokens. |
| | **UIComponentsKit** (`v1.9.0`) | Surface cards, message banners, and accessible button styling. |
| | **LocalisationKit** (`v0.8.1`) | Injected localization string resolution. |
| **Downstream Consumers** | **ShowBook** | "Know Your Developer" screen in the slide-out navigation menu. |
| | **myTV** | About & Credits screen in the sidebar navigation sheet. |
| | **Motivation Daily** | Developer profile and share studio attribution view. |

---

## 4. API Contracts & Practical Code Examples

### 1. Injected Host Profile Integration
```swift
import SwiftUI
import DeveloperProfileKit
import LocalizationKit

struct AboutScreen: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            DeveloperProfileView(
                appInfo: DeveloperAppInfo(
                    appName: "ShowBook",
                    version: "1.0.0",
                    buildNumber: "42",
                    disclaimer: "ShowBook utilizes the public Open Library API."
                ),
                labels: DeveloperProfileLabels(
                    title: L10n.About.title.localized,
                    biographyHeader: L10n.About.bioHeader.localized,
                    experienceHeader: L10n.About.experienceHeader.localized,
                    connectHeader: L10n.About.connectHeader.localized
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
```

---

## 5. Verification & Testing

```sh
# Run DeveloperProfileKit unit tests and JSON decoding validation
swift test

# Validate architectural boundaries and symbol tokenization
python3 /path/to/UIComponentsKit/Scripts/check_architecture.py --workspace-root /path/to/Projects
```

---

## 6. End-to-End Ecosystem Connectivity

```mermaid
graph TD
    subgraph CoreServices ["Shared Core Services (SPMs)"]
        FoundationKit["FoundationKit<br/>(System Clock, Unified Logging, Thread Safety)"]
        LocalisationKit["LocalisationKit<br/>(Typed Strings, Pluralization, String Catalogs)"]
        DesignTokensKit["DesignTokensKit<br/>(BrandPalettes, ColorTheme, Typography, Metrics, SF Symbols)"]
        CommonNetworkingKit["CommonNetworkingKit<br/>(HTTPClient, URLSession, RequestBuilder, Interceptors)"]
        AppStubData["AppStubData<br/>(Synthetic Fixtures, Offline Catalogs, Test Scenarios)"]
    end

    subgraph UIServices ["Shared Presentation & Auth (SPMs)"]
        UIComponentsKit["UIComponentsKit<br/>(CatalogTile, SurfaceCard, StateMessage, Recipes)"]
        AuthKit["AuthKit & AuthKitUI<br/>(SessionManager, AppAuthGate, AccountToolbarItem)"]
        DeveloperProfileKit["DeveloperProfileKit<br/>(DeveloperProfileView, Runtime Overlays)"]
        SnapshotTestingKit["SnapshotTestingKit<br/>(Subpixel Comparison, Golden Baseline Engine)"]
    end

    subgraph HostApps ["Host Applications"]
        ShowBook["ShowBook<br/>(Book Discovery, Core Data Persistence, Open Library)"]
        MyTV["myTV<br/>(IPTV Browser, AVPlayer Lifecycle, Directory Cache)"]
        MotivationDaily["Motivation Daily<br/>(Card Feed, Quote Persistence, Image Export Studio)"]
    end

    subgraph QualityGates ["CI/CD Automation & Tooling"]
        ArchitectureGuard["check_architecture.py<br/>(Boundary Enforcement, Zero Token Leakage)"]
        SnapshotVerifier["verify-snapshot-baselines.py<br/>(Visual Regression Gate)"]
        GHActions["GitHub Actions CI<br/>(Fast Lane, Smoke Lane, Release Build Verification)"]
    end

    %% Dependencies between Shared SPMs
    DesignTokensKit --> UIComponentsKit
    LocalisationKit --> UIComponentsKit
    DesignTokensKit --> AuthKit
    UIComponentsKit --> AuthKit
    FoundationKit --> CommonNetworkingKit
    DesignTokensKit --> DeveloperProfileKit
    UIComponentsKit --> DeveloperProfileKit
    LocalisationKit --> DeveloperProfileKit

    %% Dependencies from Host Apps to Shared SPMs
    DesignTokensKit --> ShowBook
    UIComponentsKit --> ShowBook
    AuthKit --> ShowBook
    CommonNetworkingKit --> ShowBook
    DeveloperProfileKit --> ShowBook
    AppStubData --> ShowBook

    DesignTokensKit --> MyTV
    UIComponentsKit --> MyTV
    AuthKit --> MyTV
    CommonNetworkingKit --> MyTV
    DeveloperProfileKit --> MyTV
    AppStubData --> MyTV

    DesignTokensKit --> MotivationDaily
    UIComponentsKit --> MotivationDaily
    AuthKit --> MotivationDaily
    CommonNetworkingKit --> MotivationDaily
    DeveloperProfileKit --> MotivationDaily
    AppStubData --> MotivationDaily

    %% Testing & Verification Linkage
    SnapshotTestingKit -.-> ShowBook
    SnapshotTestingKit -.-> MyTV
    SnapshotTestingKit -.-> MotivationDaily

    ArchitectureGuard --> HostApps
    ArchitectureGuard --> CoreServices
    ArchitectureGuard --> UIServices
    SnapshotVerifier --> SnapshotTestingKit
    GHActions --> HostApps
    GHActions --> UIServices
    GHActions --> CoreServices
```

---

## 7. Canonical Notion Dashboards & Governance Links

- [iOS Portfolio — Engineering Tickets Dashboard](https://app.notion.com/p/c20d7f4b133b44499c8ac0b4d5f6249e?pvs=204)
- [iOS Portfolio — Master Document](https://app.notion.com/p/40ffa5f855b98192ad2ede66a5d36fe7)
- [Architecture Boundary Validator (`check_architecture.py`)](file:///Users/anuragchourasia/Desktop/Projects/UIComponentsKit/Scripts/check_architecture.py)
- [Release & Gate Policy Documentation (`Docs/MASTER.md`)](file:///Users/anuragchourasia/Desktop/Projects/Docs/MASTER.md)
