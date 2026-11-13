import Foundation
import Observation

@MainActor
@Observable
final class CountdownStore {
    private(set) var items: [CountdownItem] = [] {
        didSet { onCountChanged?(items.count) }
    }
    @ObservationIgnored var onCountChanged: ((Int) -> Void)?
    @ObservationIgnored private let reminders: ReminderScheduler?

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        let hasDataOverride = !(ProcessInfo.processInfo.environment["LITECOUNT_DATA_DIR"] ?? "").isEmpty
        reminders = fileURL == nil && !hasDataOverride ? ReminderScheduler() : nil
        load()
        reminders?.synchronize(items)
    }

    func upcoming(at now: Date) -> [CountdownItem] {
        items.filter { $0.targetDate > now }.sorted { $0.targetDate < $1.targetDate }
    }

    func expired(at now: Date) -> [CountdownItem] {
        items.filter { $0.targetDate <= now }.sorted { $0.targetDate > $1.targetDate }
    }

    func upcomingCount(at now: Date) -> Int {
        items.count { $0.targetDate > now }
    }

    func add(name rawName: String, targetDate: Date, icon rawIcon: String, colorHex rawColorHex: String, reminderLead: String? = nil) {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let date = targetDate.roundedToMinute
        items.append(CountdownItem(
            name: name,
            targetDate: date,
            icon: IconCatalog.sanitized(rawIcon),
            colorHex: IconPalette.sanitized(rawColorHex),
            reminderLead: reminderLead
        ))
        save()
        reminders?.synchronize(items, requestPermission: reminderLead != nil)
    }

    func update(
        id: UUID,
        name rawName: String,
        targetDate: Date,
        icon rawIcon: String,
        colorHex rawColorHex: String,
        reminderLead: String?
    ) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        items[index].name = name
        items[index].targetDate = targetDate.roundedToMinute
        items[index].icon = IconCatalog.sanitized(rawIcon)
        items[index].colorHex = IconPalette.sanitized(rawColorHex)
        items[index].reminderLead = reminderLead
        save()
        reminders?.synchronize(items, requestPermission: reminderLead != nil)
    }

    func delete(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
        reminders?.synchronize(items)
    }

    /// QA/marketing capture only: start from an empty isolated store.
    func deleteAllForCapture() {
        items = []
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: backupFileURL)
        reminders?.synchronize(items)
    }

    private func load() {
        if let savedItems = decodeItems(at: fileURL) {
            items = savedItems
            return
        }

        if let backupItems = decodeItems(at: backupFileURL) {
            items = backupItems
            NSLog("LiteCount 已从本地备份恢复数据")
            return
        }

        items = []
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try preserveValidBackup()
            let data = try JSONEncoder.liteCount.encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            NSLog("LiteCount 保存失败: %@", error.localizedDescription)
        }
    }

    private var backupFileURL: URL {
        fileURL.deletingLastPathComponent().appending(path: "items.backup.json")
    }

    private func decodeItems(at url: URL) -> [CountdownItem]? {
        guard
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder.liteCount.decode([CountdownItem].self, from: data)
        else { return nil }
        return decoded
    }

    private func preserveValidBackup() throws {
        guard
            let data = try? Data(contentsOf: fileURL),
            (try? JSONDecoder.liteCount.decode([CountdownItem].self, from: data)) != nil
        else {
            return
        }
        try data.write(to: backupFileURL, options: .atomic)
    }

    private static func defaultFileURL() -> URL {
        // QA/marketing runs use an explicit isolated directory; real data stays untouched.
        if let override = ProcessInfo.processInfo.environment["LITECOUNT_DATA_DIR"], !override.isEmpty {
            return URL(fileURLWithPath: override, isDirectory: true).appending(path: "items.json")
        }
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appending(path: ProductIdentity.dataDirectoryName, directoryHint: .isDirectory)
            .appending(path: "items.json")
    }
}

private extension JSONEncoder {
    static var liteCount: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var liteCount: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension Date {
    var roundedToMinute: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components) ?? self
    }
}
