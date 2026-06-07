import SwiftUI
import GitaKit

/// P0 — Onboarding (gita-pages.md §3). First launch only. Sets the notification preference and
/// lands on Home. **No sign-in step** — v1 uses CloudKit-only identity (gita-security.md §2,
/// resolved this session). Skippable to a sensible default so the user is never blocked.
///
/// Phase 0: the controls are placeholders that persist a `Preferences` value; real notification
/// scheduling is Phase 4.
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var prefs = AppGroupStore.shared.readPreferences()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Daily Gita")
                    .font(.largeTitle)
                Text("A daily moment of Gita wisdom on your home screen.")
                    .multilineTextAlignment(.center)
            }

            Form {
                Section("Daily reminder") {
                    Toggle("Enable notifications", isOn: $prefs.notificationsEnabled)
                    Picker("When", selection: $prefs.notificationMode) {
                        Text("Within 8am–8pm").tag(Preferences.NotificationMode.window)
                        Text("A specific time").tag(Preferences.NotificationMode.specific)
                        Text("A custom range").tag(Preferences.NotificationMode.range)
                    }
                    .disabled(!prefs.notificationsEnabled)
                }
            }
            .frame(maxHeight: 220)

            Spacer()

            Button("Begin") {
                AppGroupStore.shared.writePreferences(prefs)
                onFinish()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
    }
}
