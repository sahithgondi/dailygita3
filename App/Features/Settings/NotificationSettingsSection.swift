import SwiftUI
import GitaKit

/// The shared "Daily reminder" controls — enable toggle, mode picker, and the time picker(s) for the
/// chosen mode. Used by both Onboarding (P0) and Settings (P7) so the controls stay identical
/// (gita-pages.md §3/§10). Binds a `Preferences` the caller persists.
///
/// Time is stored as minutes-from-midnight in `Preferences`; the `DatePicker`s bridge that to a Date.
struct NotificationSettingsSection: View {
    @Binding var prefs: Preferences

    var body: some View {
        Section("Daily reminder") {
            Toggle("Enable notifications", isOn: $prefs.notificationsEnabled)

            if prefs.notificationsEnabled {
                Picker("When", selection: $prefs.notificationMode) {
                    Text("Within 8am–8pm").tag(Preferences.NotificationMode.window)
                    Text("A specific time").tag(Preferences.NotificationMode.specific)
                    Text("A custom range").tag(Preferences.NotificationMode.range)
                }

                switch prefs.notificationMode {
                case .window:
                    Text("A reminder at a random time between 8:00 AM and 8:00 PM.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                case .specific:
                    DatePicker("Time", selection: time($prefs.windowStart), displayedComponents: .hourAndMinute)
                case .range:
                    DatePicker("From", selection: time($prefs.windowStart), displayedComponents: .hourAndMinute)
                    DatePicker("To", selection: time($prefs.windowEnd), displayedComponents: .hourAndMinute)
                    Text("A reminder at a random time in this range each day.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// Bridge a minutes-from-midnight `Binding<Int>` to the `Binding<Date>` a DatePicker wants.
    private func time(_ minutes: Binding<Int>) -> Binding<Date> {
        Binding(
            get: { Calendar.current.date(bySettingHour: minutes.wrappedValue / 60,
                                         minute: minutes.wrappedValue % 60, second: 0, of: Date()) ?? Date() },
            set: {
                let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                minutes.wrappedValue = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        )
    }
}
