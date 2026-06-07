import SwiftUI
import GitaKit

/// P7 — Settings (gita-pages.md §10). Editable preferences: notifications, font size, appearance,
/// about. No account section — v1 is CloudKit-only with no visible sign-in (gita-security.md §2).
///
/// Phase 0 persists `Preferences` to the App Group store (device-local in v1, impl plan §11.3);
/// notification scheduling and live font/appearance application are wired in later milestones.
struct SettingsView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var prefs = AppGroupStore.shared.readPreferences()

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(v) (\(b))"
    }

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $prefs.notificationsEnabled)
                Picker("When", selection: $prefs.notificationMode) {
                    Text("Within 8am–8pm").tag(Preferences.NotificationMode.window)
                    Text("A specific time").tag(Preferences.NotificationMode.specific)
                    Text("A custom range").tag(Preferences.NotificationMode.range)
                }
                .disabled(!prefs.notificationsEnabled)
            }

            Section("Reading") {
                Picker("Appearance", selection: $prefs.appearance) {
                    Text("System").tag(Preferences.Appearance.system)
                    Text("Light").tag(Preferences.Appearance.light)
                    Text("Dark").tag(Preferences.Appearance.dark)
                }
                VStack(alignment: .leading) {
                    Text("Font size")
                    Slider(value: $prefs.fontScale, in: 0.8...1.6, step: 0.1)
                }
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Link("Privacy policy", destination: URL(string: "https://example.com/privacy")!)
                LabeledContent("Content", value: "Bhagavad Gita (public domain)")
            }

            Section {
                Button("Reset onboarding") { hasOnboarded = false }
            }
        }
        .navigationTitle("Settings")
        // Persist on any change so edits survive without an explicit save button.
        .onChange(of: prefs) { _, new in
            AppGroupStore.shared.writePreferences(new)
        }
    }
}
