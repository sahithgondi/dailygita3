import SwiftUI
import GitaKit

/// P0 — Onboarding (gita-pages.md §3). First launch only. Sets the notification preference and
/// lands on Home. **No sign-in step** — v1 uses CloudKit-only identity (gita-security.md §2,
/// resolved this session). Skippable to a sensible default so the user is never blocked.
///
struct OnboardingView: View {
    let onFinish: () -> Void

    @Environment(AppModel.self) private var model
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
                NotificationSettingsSection(prefs: $prefs)
            }
            .frame(maxHeight: 300)

            Spacer()

            Button("Begin") {
                AppGroupStore.shared.writePreferences(prefs)
                // Ask for permission (if reminders are on) and schedule the rolling daily window.
                Task {
                    if prefs.notificationsEnabled {
                        _ = await model.requestNotificationAuthorization()
                    }
                    model.scheduleDailyNotifications()
                }
                onFinish()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
    }
}
