import SwiftUI
import DesignTokensKit
import UIComponentsKit
import LocalizationKit

/// Scrollable content; the host owns navigation, connectivity and appearance controls.
public struct DeveloperProfileView: View {
    private let profile: DeveloperProfile
    private let app: DeveloperAppInfo
    private let layout: CatalogLayout
    private let customLabels: DeveloperProfileLabels?
    @Environment(\.localizationProvider) private var localizationProvider
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.openURL) private var openURL
    @State private var linkFailed = false

    public init(
        profile: DeveloperProfile = .anurag,
        app: DeveloperAppInfo,
        layout: CatalogLayout = .list,
        labels: DeveloperProfileLabels? = nil
    ) {
        self.profile = profile
        self.app = app
        self.layout = layout
        self.customLabels = labels
    }

    private var labels: DeveloperProfileLabels {
        customLabels ?? DeveloperProfileLabels(provider: localizationProvider)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: \.zero) {
                VStack(spacing: \.sixteen) {
                    Image(profile.portrait, bundle: .module)
                        .resizable().scaledToFit().frame(width: \.p100, height: \.p100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ColorTheme.default.secondary, lineWidth: StrokeWidthTheme.default.one))
                        .accessibilityHidden(true)
                    Text(profile.name).font(Typography.title2.weight(.bold)).accessibilityAddTraits(.isHeader)
                    Text(profile.role).foregroundStyle(\.secondary)
                    DeveloperSummary(text: profile.summary, labels: labels)
                }.padding(\.sixteen)
                Divider()
                VStack(alignment: .leading, spacing: \.eight) {
                    Text(labels.appInformation).font(\.headline).accessibilityAddTraits(.isHeader)
                    Text(app.name)
                    Text("\(labels.version) \(app.version) (\(app.build))").foregroundStyle(\.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(\.sixteen)
                Divider()
                VStack(alignment: .leading, spacing: \.ten) {
                    Text(labels.disclaimer).font(\.headline).accessibilityAddTraits(.isHeader)
                    Text(.init(app.disclaimer)).font(\.footnote)
                        .foregroundStyle(\.secondary).tint(\.blue)
                        .fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(\.sixteen)
                Divider()
                socialLinks
            }
        }
        .background(\.grouped)
        .alert(labels.errorTitle, isPresented: $linkFailed) {
            Button(labels.okay, role: .cancel) {}
        } message: { Text(labels.errorMessage) }
    }

    private var socialLinks: some View {
        VStack(alignment: .leading, spacing: \.sixteen) {
            Text(labels.social).font(\.headline).accessibilityAddTraits(.isHeader)
            if layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize) == .grid {
                LazyVGrid(columns: [.init(.adaptive(minimum: DesignMetricTheme.default.p120))], spacing: SpacingTheme.default.twelve) {
                    ForEach(profile.links) { link in
                        linkButton(link, grid: true)
                    }
                }
            } else {
                VStack(spacing: \.zero) {
                    ForEach(profile.links) { link in
                        linkButton(link, grid: false)
                        if link.id != profile.links.last?.id { Divider().padding(.horizontal, \.sixteen) }
                    }
                }.background(\.groupedSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: \.r12))
            }
        }.padding(\.sixteen)
    }

    private func linkButton(_ link: DeveloperLink, grid: Bool) -> some View {
        Button {
            guard link.canOpen else { linkFailed = true; return }
            openURL(link.url) { accepted in if !accepted { linkFailed = true } }
        } label: {
            Group {
                if grid {
                    VStack(spacing: \.twelve) {
                        icon(link, size: \.p64)
                        Text(link.title).font(\.headline).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity, minHeight: DesignMetricTheme.default.p110)
                } else {
                    HStack(spacing: \.twelve) {
                        icon(link, size: \.p36)
                        Text(link.title).font(\.headline)
                        Spacer()
                    }
                }
            }
            .foregroundStyle(\.primary)
            .padding(\.sixteen)
            .background(\.groupedSecondary)
            .clipShape(RoundedRectangle(cornerRadius: \.r20))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(link.title).accessibilityHint(labels.linkHint)
    }

    private func icon(_ link: DeveloperLink, size: KeyPath<DesignMetricTheme, CGFloat>) -> some View {
        Image(link.icon, bundle: .module).resizable().scaledToFit()
            .frame(size: size).accessibilityHidden(true)
    }
}

private struct DeveloperSummary: View {
    let text: String
    let labels: DeveloperProfileLabels
    @State private var expanded = false
    @State private var displayed = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let previewWordLimit = 13

    var body: some View {
        VStack(alignment: .leading, spacing: \.twelve) {
            Text(expanded ? (reduceMotion || voiceOver ? text : displayed) : SummaryText.preview(text, wordLimit: Self.previewWordLimit))
                .font(\.body)
                .lineLimit(expanded ? nil : (dynamicTypeSize.isAccessibilitySize ? CatalogMetrics.accessibleTitleLines : TextLineLimit.p2))
                .frame(maxWidth: .infinity, alignment: .leading)
            if text.split(whereSeparator: \.isWhitespace).count > Self.previewWordLimit {
                Button(expanded ? labels.showLess : labels.readMore) { expanded.toggle() }
                    .font(Typography.body.weight(.semibold))
            }
        }
        .padding(\.sixteen)
        .task(id: expanded) {
            guard expanded else { displayed = ""; return }
            // View-scoped task cancels when collapsed or removed from navigation.
            guard !reduceMotion, !voiceOver else { displayed = text; return }
            let words = text.split(separator: " ", omittingEmptySubsequences: false)
            for count in min(Self.previewWordLimit, words.count)...words.count {
                guard !Task.isCancelled else { return }
                displayed = words.prefix(count).joined(separator: " ")
                do { try await Task.sleep(for: .milliseconds(150)) } catch { return }
            }
        }
    }
}
