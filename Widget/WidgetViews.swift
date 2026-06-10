import SwiftUI
import WidgetKit
import GitaKit

/// Renders a `DailyShlokaEntry` across the supported families (gita-pages.md W1/W2). The verse is now
/// padapātha (one pāda per line, daṇḍa marks): the compact families show the **first pāda** as a clean
/// teaser (no mid-verse truncation), while `systemLarge` shows the whole verse + meaning.
struct DailyGitaWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DailyShlokaEntry

    private var payload: DailyShlokaPayload { entry.payload ?? Provider.placeholderPayload }

    var body: some View {
        switch family {
        case .systemSmall:
            small
        case .systemMedium:
            medium
        case .systemLarge:
            large
        case .accessoryRectangular:
            rectangular
        case .accessoryInline:
            Text("Gita \(payload.reference): \(payload.firstPada)")
        default:
            small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Gita").font(.caption2).foregroundStyle(.secondary)
            Text(payload.firstPada).font(.callout).lineLimit(3)
            Spacer(minLength: 0)
            Text(payload.reference).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 6) {
            // First hemistich (first two pādas) as the teaser.
            Text(payload.verseLines.prefix(2).joined(separator: "\n"))
                .font(.headline)
                .lineLimit(2)
            Text(payload.meaning).font(.caption).lineLimit(3)
            Text(payload.reference).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var large: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let speaker = payload.speaker {
                Text(speaker).font(.subheadline.weight(.semibold))
            }
            verse
            Divider()
            Text(payload.meaning).font(.callout).lineLimit(4)
            Spacer(minLength: 0)
            Text(payload.reference).font(.caption2).foregroundStyle(.secondary)
        }
    }

    /// Full padapātha — one pāda per line, 2nd/4th indented (mirrors the app's `VerseView` rule).
    private var verse: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(payload.verseLines.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, index.isMultiple(of: 2) ? 0 : 18)
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(payload.reference).font(.caption2)
            Text(payload.firstPada).font(.caption).lineLimit(2)
        }
    }
}
