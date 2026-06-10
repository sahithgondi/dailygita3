import Foundation
import UserNotifications
import GitaKit

/// Thin bridge to `UNUserNotificationCenter`: turns a `[PlannedNotification]` (built by GitaKit's
/// unit-tested `NotificationPlanner`) into pending local notifications. Kept deliberately minimal —
/// all the *what/when* logic is in the planner; this only talks to the system.
struct NotificationScheduler {
    private let center = UNUserNotificationCenter.current()

    /// Ask for alert + sound permission. Returns whether it's granted.
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func isAuthorized() async -> Bool {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    /// Replace every pending reminder with the given plan. An empty plan (notifications disabled)
    /// simply clears them.
    func apply(_ plan: [PlannedNotification]) {
        center.removeAllPendingNotificationRequests()
        for item in plan {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            content.userInfo = ["shlokaID": item.shlokaID, "chapter": item.chapter]
            let trigger = UNCalendarNotificationTrigger(dateMatching: item.fireDate, repeats: false)
            center.add(UNNotificationRequest(identifier: item.id, content: content, trigger: trigger))
        }
    }
}
