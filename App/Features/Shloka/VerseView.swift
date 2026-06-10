import SwiftUI
import GitaKit

/// The padapātha verse block — the speaker label (if any) above one pāda per line, with the 2nd and
/// 4th pādas indented (gita-ui.md §4). Shared by the reading card (`ShlokaCard`) and the Home
/// daily-shloka card so the layout rule lives in one place.
struct VerseView: View {
    let shloka: Shloka

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padaSpacing) {
            if let speaker = shloka.speaker {
                Text(speaker)
                    .font(Theme.speakerFont)
                    .padding(.bottom, 2)
            }
            // One pāda per line; indent the odd-indexed lines (the 2nd and 4th pādas).
            ForEach(Array(shloka.verseLines.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .font(Theme.verseFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, index.isMultiple(of: 2) ? 0 : Theme.padaIndent)
            }
        }
    }
}
