# Changelog

## 1.2.0

- Centralize `DeveloperProfileLabels` copy ownership through injected localization (`init(resolving:)` and memberwise `init`) with deterministic key-echo standalone fallback instead of duplicated English literals (`IOS-59`).

## 1.0.0

- Extract MyTV's developer profile, bundled portrait/social artwork, biography and social links.
- Configurable host app metadata, disclaimer and localized labels.
- Accessible list/grid links and cancellable expansion animation respecting VoiceOver and Reduce Motion.
- Exact shared token/component dependencies and private consumer CI access.
