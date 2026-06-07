import WidgetKit
import SwiftUI

/// The home- and lock-screen widget showing the day's shloka (gita-pages.md W1/W2). Static
/// configuration (no user-configurable intent in v1). Tapping opens the app to Home (P1) — handled
/// by the default deep link into the app.
struct DailyGitaWidget: Widget {
    let kind = "DailyGitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyGitaWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Gita")
        .description("The day’s shloka on your home and lock screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct DailyGitaWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyGitaWidget()
    }
}
