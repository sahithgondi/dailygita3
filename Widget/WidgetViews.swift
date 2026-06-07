import SwiftUI
import WidgetKit
import GitaKit

/// Renders a `DailyShlokaEntry` across the supported families (gita-pages.md W1/W2).
/// W1 home screen: small (reference + short line) and medium (transliteration + partial meaning).
/// W2 lock screen: compact accessory presentations.
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
        case .accessoryRectangular:
            rectangular
        case .accessoryInline:
            Text("Gita \(payload.reference): \(payload.transliteration)")
        default:
            small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Gita").font(.caption2).foregroundStyle(.secondary)
            Text(payload.transliteration).font(.caption).lineLimit(3)
            Spacer(minLength: 0)
            Text(payload.reference).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(payload.transliteration).font(.headline).lineLimit(2)
            Text(payload.meaning).font(.caption).lineLimit(3)
            Text(payload.reference).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(payload.reference).font(.caption2)
            Text(payload.transliteration).font(.caption).lineLimit(2)
        }
    }
}
