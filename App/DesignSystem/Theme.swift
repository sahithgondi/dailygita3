import SwiftUI

/// Visual design tokens for Daily Gita. The single place layout/type constants live, so screens stay
/// free of magic numbers. The rationale and rules for these values are documented in `gita-ui.md`
/// (the design source of truth); this enum is their concrete expression. Keep them in sync.
enum Theme {
    // ── Layout ───────────────────────────────────────────────────────────────────────────────────
    /// Horizontal inset from the screen edge to the cards.
    static let screenMargin: CGFloat = 16
    /// Vertical gap between stacked shloka cards.
    static let cardSpacing: CGFloat = 12
    /// Inner padding inside a shloka card.
    static let cardPadding: CGFloat = 16
    /// Corner radius of a shloka card.
    static let cardRadius: CGFloat = 14
    /// Leading indent applied to the 2nd and 4th pādas (odd-indexed verse lines) — the traditional
    /// padapātha layout (see `gita-ui.md` §verse layout).
    static let padaIndent: CGFloat = 22
    /// Vertical spacing between pāda lines within a verse.
    static let padaSpacing: CGFloat = 3

    // ── Surfaces ─────────────────────────────────────────────────────────────────────────────────
    /// Page background behind the cards; cards sit one step lighter/darker on top.
    static let pageBackground = Color(uiColor: .systemGroupedBackground)
    /// Shloka card fill.
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    /// The bookmark star indicator color.
    static let bookmarkStar = Color.yellow

    // ── Type ─────────────────────────────────────────────────────────────────────────────────────
    // System text styles so Dynamic Type and the Settings font-scale carry through automatically.
    /// The "<name> uvāca" speaker label.
    static let speakerFont = Font.subheadline.weight(.semibold)
    /// The verse pādas (transliteration) — the primary reading text.
    static let verseFont = Font.body
    /// The English meaning beneath the verse.
    static let meaningFont = Font.callout
}
