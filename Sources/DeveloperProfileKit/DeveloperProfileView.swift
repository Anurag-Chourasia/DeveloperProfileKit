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
            VStack(spacing: Spacing.zero) {
                VStack(spacing: Spacing.sixteen) {
                    Image(profile.portrait, bundle: .module)
                        .resizable().scaledToFit().frame(width: DesignMetric.p100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(DesignColor.secondary, lineWidth: StrokeWidth.one))
                        .accessibilityHidden(true)
                    Text(profile.name).font(Typography.title2.weight(.bold)).accessibilityAddTraits(.isHeader)
                    Text(profile.role).foregroundStyle(DesignColor.secondary)
                    DeveloperSummary(text: profile.summary, labels: labels)
                }.padding(.all, Spacing.system)
                Divider()
                VStack(alignment: .leading, spacing: Spacing.eight) {
                    Text(labels.appInformation).font(Typography.headline).accessibilityAddTraits(.isHeader)
                    Text(app.name)
                    Text("\(labels.version) \(app.version) (\(app.build))").foregroundStyle(DesignColor.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.all, Spacing.system)
                Divider()
                VStack(alignment: .leading, spacing: Spacing.ten) {
                    Text(labels.disclaimer).font(Typography.headline).accessibilityAddTraits(.isHeader)
                    Text(.init(app.disclaimer)).font(Typography.footnote)
                        .foregroundStyle(DesignColor.secondary).tint(DesignColor.blue)
                        .fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.all, Spacing.system)
                Divider()
                socialLinks
            }
        }
        .background(DesignColor.grouped)
        .alert(labels.errorTitle, isPresented: $linkFailed) {
            Button(labels.okay, role: .cancel) {}
        } message: { Text(labels.errorMessage) }
    }

    private var socialLinks: some View {
        VStack(alignment: .leading, spacing: Spacing.sixteen) {
            Text(labels.social).font(Typography.headline).accessibilityAddTraits(.isHeader)
            if layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize) == .grid {
                LazyVGrid(columns: [.init(.adaptive(minimum: DesignMetric.p120))], spacing: Spacing.twelve) {
                    ForEach(profile.links) { link in
                        linkButton(link, grid: true)
                    }
                }
            } else {
                VStack(spacing: Spacing.zero) {
                    ForEach(profile.links) { link in
                        linkButton(link, grid: false)
                        if link.id != profile.links.last?.id { Divider().padding(.horizontal, Spacing.sixteen) }
                    }
                }.background(DesignColor.groupedSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignMetric.p12))
            }
        }.padding(.all, Spacing.system)
    }

    private func linkButton(_ link: DeveloperLink, grid: Bool) -> some View {
        Button {
            guard link.canOpen else { linkFailed = true; return }
            openURL(link.url) { accepted in if !accepted { linkFailed = true } }
        } label: {
            Group {
                if grid {
                    VStack(spacing: Spacing.twelve) {
                        icon(link, size: DesignMetric.p64)
                        Text(link.title).font(Typography.headline).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity, minHeight: DesignMetric.p110)
                } else {
                    HStack(spacing: Spacing.twelve) {
                        icon(link, size: DesignMetric.p36)
                        Text(link.title).font(Typography.headline)
                        Spacer()
                    }
                }
            }
            .foregroundStyle(DesignColor.primary)
            .padding(.all, Spacing.system)
            .background(DesignColor.groupedSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DesignMetric.p20))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(link.title).accessibilityHint(labels.linkHint)
    }

    private func icon(_ link: DeveloperLink, size: CGFloat) -> some View {
        Image(link.icon, bundle: .module).resizable().scaledToFit()
            .frame(width: size, height: size).accessibilityHidden(true)
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

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.twelve) {
            Text(expanded ? (reduceMotion || voiceOver ? text : displayed) : SummaryText.preview(text))
                .font(Typography.body)
                .lineLimit(expanded ? nil : (dynamicTypeSize.isAccessibilitySize ? CatalogMetrics.accessibleTitleLines : TextLineLimit.p2))
                .frame(maxWidth: .infinity, alignment: .leading)
            if text.split(whereSeparator: \.isWhitespace).count > 13 {
                Button(expanded ? labels.showLess : labels.readMore) { expanded.toggle() }
                    .font(Typography.body.weight(.semibold))
            }
        }
        .padding(.all, Spacing.system)
        .task(id: expanded) {
            guard expanded else { displayed = ""; return }
            // View-scoped task cancels when collapsed or removed from navigation.
            guard !reduceMotion, !voiceOver else { displayed = text; return }
            let words = text.split(separator: " ", omittingEmptySubsequences: false)
            for count in min(13, words.count)...words.count {
                guard !Task.isCancelled else { return }
                displayed = words.prefix(count).joined(separator: " ")
                do { try await Task.sleep(for: .milliseconds(150)) } catch { return }
            }
        }
    }
}
