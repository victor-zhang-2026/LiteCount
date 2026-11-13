import Foundation
import UserNotifications

enum ReminderDuration {
    // Accept free-form day, hour and minute components in either app language.
    private static let pattern = try! NSRegularExpression(
        pattern: #"^\s*(?:(\d+)\s*(?:天|d(?:ays?)?))?\s*(?:(\d+)\s*(?:小时|h(?:ours?)?))?\s*(?:(\d+)\s*(?:分钟|m(?:in(?:utes?)?)?))?\s*$"#,
        options: [.caseInsensitive]
    )

    static func seconds(_ text: String) -> TimeInterval? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = pattern.firstMatch(in: text, range: range) else { return nil }
        var total: Int64 = 0
        for (index, multiplier) in [(1, Int64(86_400)), (2, 3_600), (3, 60)] {
            guard let componentRange = Range(match.range(at: index), in: text) else { continue }
            guard let value = Int64(text[componentRange]) else { return nil }
            let (part, multipliedOverflow) = value.multipliedReportingOverflow(by: multiplier)
            let (sum, addedOverflow) = total.addingReportingOverflow(part)
            guard !multipliedOverflow && !addedOverflow else { return nil }
            total = sum
        }
        return total > 0 ? TimeInterval(total) : nil
    }
}

@MainActor
final class ReminderScheduler {
    private let center = UNUserNotificationCenter.current()
    private let prefix = "litecount.reminder."
    private var synchronizationTask: Task<Void, Never>?

    func synchronize(_ items: [CountdownItem], requestPermission: Bool = false) {
        let previous = synchronizationTask
        synchronizationTask = Task {
            await previous?.value
            let settings = await center.notificationSettings()
            var authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            if requestPermission && settings.authorizationStatus == .notDetermined {
                authorized = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            }
            let pending = await center.pendingNotificationRequests()
            let existingIDs = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: existingIDs)

            guard authorized else { return }
            let now = Date.now
            for item in items {
                guard let text = item.reminderLead, let lead = ReminderDuration.seconds(text) else { continue }
                let fireDate = item.targetDate.addingTimeInterval(-lead)
                guard fireDate > now && fireDate < item.targetDate else { continue }
                let content = UNMutableNotificationContent()
                content.title = item.name
                content.body = L10n.reminderBody(lead)
                content.sound = .default
                var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
                components.calendar = Calendar.current
                components.timeZone = TimeZone.current
                let request = UNNotificationRequest(
                    identifier: prefix + item.id.uuidString,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                )
                do { try await center.add(request) }
                catch { NSLog("LiteCount 提醒安排失败: %@", error.localizedDescription) }
            }
        }
    }
}

final class ReminderPresentationDelegate: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
