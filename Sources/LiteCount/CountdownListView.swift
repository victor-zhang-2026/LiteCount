import AppKit
import SwiftUI

struct CountdownListView: View {
    @Bindable var store: CountdownStore
    let controller: FloatingWindowController

    @State private var showingEditor = false
    @State private var showingExpired = false
    @State private var editingItem: CountdownItem?
    @State private var deleteCandidate: CountdownItem?
    @State private var languageLocale = AppFormat.locale()
    @State private var panelLockVersion = UUID()
    @AppStorage("appAppearance") private var appearanceRawValue = AppearanceMode.light.rawValue

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceRawValue) ?? .light
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(appearanceMode == .dark ? Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255) : .white)

            VStack(spacing: 0) {
                header
                Divider().opacity(0.45)
                if showingEditor {
                    CountdownEditor(
                        controller: controller,
                        editing: editingItem,
                        onSave: { name, date, icon, colorHex, reminderLead in
                            if let editingItem {
                                store.update(id: editingItem.id, name: name, targetDate: date, icon: icon, colorHex: colorHex, reminderLead: reminderLead)
                            } else {
                                store.add(name: name, targetDate: date, icon: icon, colorHex: colorHex, reminderLead: reminderLead)
                            }
                            closeEditor()
                        },
                        onDelete: {
                            if let editingItem {
                                controller.setConfirmationActive(true)
                                deleteCandidate = editingItem
                            }
                        },
                        onCancel: { closeEditor() }
                    )
                    .transition(.opacity)
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        listContent(at: timeline.date)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .environment(\.locale, languageLocale)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if deleteCandidate != nil {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.black.opacity(appearanceMode == .dark ? 0.48 : 0.24))
                deletionConfirmation
            }
        }
        .frame(width: 360, height: 352)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .preferredColorScheme(appearanceMode.colorScheme)
        .onHover(perform: controller.listHoverChanged)
        .onReceive(NotificationCenter.default.publisher(for: .liteCountPanelWillClose)) { _ in
            // Editor drafts survive panel close/open within the session.
            deleteCandidate = nil
            controller.setConfirmationActive(false)
        }
    }

    private func closeEditor() {
        showingEditor = false
        editingItem = nil
    }

    private var deletionConfirmation: some View {
        VStack(spacing: 16) {
            Text(L10n.deleteTitle)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
            Text(L10n.deleteMessage)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Button { cancelDeletion() } label: {
                    Text(L10n.cancel)
                        .foregroundStyle(Color.liteCountPrimaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.liteCountSeparator.opacity(0.35), in: Capsule())
                        .contentShape(Rectangle())
                }
                .keyboardShortcut(.cancelAction)
                Button { confirmDeletion() } label: {
                    Text(L10n.delete)
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.red.opacity(0.16), in: Capsule())
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 280)
        .background(Color.liteCountElevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 8)
    }

    private func cancelDeletion() {
        deleteCandidate = nil
        controller.setConfirmationActive(false)
    }

    private func confirmDeletion() {
        if let deleteCandidate {
            store.delete(deleteCandidate.id)
        }
        cancelDeletion()
        // The editor beneath the overlay referenced the deleted item.
        showingEditor = false
        editingItem = nil
    }

    private var header: some View {
        HStack(spacing: 7) {
            if showingExpired && !showingEditor {
                Button { showingExpired = false } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(HeaderButtonStyle())
                .fastHelp(L10n.back, horizontalOffset: 32)
            } else {
                Button {
                    controller.showAbout()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.liteCountBlue)
                        LiteCountHeaderHourglass()
                            .stroke(.white, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                            .frame(width: 28, height: 28)
                    }
                    .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .fastHelp(L10n.about)
            }
            Text(showingExpired && !showingEditor ? L10n.expired : L10n.appName)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            if !showingExpired && !showingEditor {
                Button {
                    editingItem = nil
                    showingEditor = true
                    controller.pinPanel()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                }
                .buttonStyle(HeaderButtonStyle(hoverColor: .liteCountBlue))
                .fastHelp(L10n.add)
            }

            Button {
                L10n.toggleLanguage()
                languageLocale = AppFormat.locale()
                controller.refreshAbout()
            } label: {
                Image(systemName: "globe")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(HeaderButtonStyle())
            .fastHelp(L10n.switchToEnglish)

            Button {
                controller.transitionAppearance {
                    appearanceRawValue = appearanceMode == .light
                        ? AppearanceMode.dark.rawValue
                        : AppearanceMode.light.rawValue
                }
            } label: {
                Image(systemName: appearanceMode.symbolName)
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(HeaderButtonStyle())
            .fastHelp(appearanceMode == .light ? L10n.switchToDark : L10n.switchToLight)

            if !showingExpired && !showingEditor {
                Button { showingExpired = true } label: {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(HeaderButtonStyle())
                .fastHelp(L10n.expired)
            }

            Button {
                controller.togglePanelLock()
                panelLockVersion = UUID()
            } label: {
                Image(systemName: controller.isPanelLocked ? "pin.fill" : "pin")
                    .foregroundStyle(controller.isPanelLocked ? Color.liteCountBlue : Color.primary)
                    .id(panelLockVersion)
            }
            .buttonStyle(HeaderButtonStyle())
            .fastHelp(controller.isPanelLocked ? L10n.unpinPanel : L10n.pinPanel)

            Button {
                controller.dismissPanel()
                panelLockVersion = UUID()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(HeaderButtonStyle(hoverColor: .red))
            .fastHelp(L10n.closePanel, horizontalOffset: -32)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .zIndex(10)
    }

    private func listContent(at now: Date) -> some View {
        let items = showingExpired ? store.expired(at: now) : store.upcoming(at: now)
        return VStack(spacing: 0) {
            if items.isEmpty { emptyState }
            else { countdownScroll(items: items, now: now) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "hourglass")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.liteCountSecondaryText)
            Text(showingExpired ? L10n.noExpired : store.items.isEmpty ? L10n.emptyTitle : L10n.noUpcoming)
                .font(.system(size: 13, weight: .medium))
            if !showingExpired && store.items.isEmpty {
                Text(L10n.emptyHint)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.liteCountSecondaryText)
            }
            Spacer()
        }
    }

    private func countdownScroll(items: [CountdownItem], now: Date) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    CountdownRow(
                        item: item,
                        now: now,
                        onEdit: {
                            editingItem = item
                            showingEditor = true
                            controller.pinPanel()
                        },
                        onDelete: {
                            controller.setConfirmationActive(true)
                            deleteCandidate = item
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}

private struct CountdownRow: View {
    let item: CountdownItem
    let now: Date
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var hovering = false

    private var remaining: String? { remainingText(until: item.targetDate, from: now) }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(IconPalette.color(item.colorHex))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 3) {
                MarqueeText(text: item.name)
                Text(AppFormat.dateTimeText(item.targetDate))
                    .font(.system(size: 10))
                    .foregroundStyle(Color.liteCountSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            countdownBadge
                .padding(.leading, 6)
        }
        .frame(minHeight: 40, alignment: .center)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(hovering ? Color.primary.opacity(0.045) : Color.clear)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.liteCountSeparator.opacity(0.72))
                .frame(height: 0.5)
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: onEdit)
        .onHover { hovering = $0 }
        .contextMenu {
            Button(L10n.edit, action: onEdit)
            Button(L10n.delete, role: .destructive, action: onDelete)
        }
    }

    private var countdownBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "hourglass")
                .font(.system(size: 10, weight: .semibold))
            Text(remaining ?? L10n.expired)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(remaining == nil ? Color.liteCountSecondaryText : IconPalette.color(item.colorHex))
        .padding(.horizontal, 8)
        .frame(height: 28)
        .background(
            remaining == nil ? Color.liteCountSeparator.opacity(0.24) : IconPalette.color(item.colorHex).opacity(0.12),
            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
        )
    }
}

/// Remaining "d HH:MM:SS" text; nil when the target has passed.
private func remainingText(until target: Date, from now: Date) -> String? {
    let interval = target.timeIntervalSince(now)
    guard interval > 0 else { return nil }
    let total = Int(interval)
    let days = total / 86400
    let hours = (total % 86400) / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    if days > 0 {
        return "\(days)\(L10n.dayUnit) \(String(format: "%02d:%02d:%02d", hours, minutes, seconds))"
    }
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

struct CountdownEditor: View {
    private enum ReminderUnit: Hashable { case days, hours, minutes }

    let controller: FloatingWindowController
    let editing: CountdownItem?
    let onSave: (String, Date, String, String, String?) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var date: Date
    @State private var icon: String
    @State private var colorHex: String
    @State private var reminderDays: String
    @State private var reminderHours: String
    @State private var reminderMinutes: String
    @FocusState private var focusedReminderUnit: ReminderUnit?

    init(controller: FloatingWindowController, editing: CountdownItem?, onSave: @escaping (String, Date, String, String, String?) -> Void, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.controller = controller
        self.editing = editing
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _name = State(initialValue: editing?.name ?? "")
        _date = State(initialValue: (editing?.targetDate ?? Date.now.addingTimeInterval(86_400)).roundedToMinute)
        _icon = State(initialValue: editing?.icon ?? IconCatalog.defaultSymbol)
        _colorHex = State(initialValue: editing?.colorHex ?? IconPalette.defaultHex)
        let maxLead = TimeInterval(36_500 * 86_400 + 23 * 3_600 + 59 * 60)
        let reminderMinutes = Int(min(ReminderDuration.seconds(editing?.reminderLead ?? "") ?? 0, maxLead)) / 60
        let hasReminder = reminderMinutes > 0
        _reminderDays = State(initialValue: hasReminder ? String(reminderMinutes / 1_440) : "")
        _reminderHours = State(initialValue: hasReminder ? String(reminderMinutes % 1_440 / 60) : "")
        _reminderMinutes = State(initialValue: hasReminder ? String(reminderMinutes % 60) : "")
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            editorContent(at: timeline.date)
        }
    }

    private func editorContent(at now: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            nameField
                .padding(.horizontal, 12)
                .padding(.top, 12)

            PopoverField(popoverSize: NSSize(width: 252, height: 444)) {
                pickerField(AppFormat.dateTimeText(date), symbol: "calendar")
            } popoverContent: {
                DateTimePickerPopoverView(date: $date)
            }
            .frame(height: 36)
            .padding(.horizontal, 12)
            .padding(.top, 10)

            HStack(spacing: 8) {
                Image(systemName: reminderSeconds == 0 ? "bell" : "bell.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(reminderSeconds == 0 ? Color.liteCountSecondaryText : Color.liteCountBlue)
                    .help(L10n.reminderLabel)
                    .accessibilityLabel(L10n.reminderLabel)
                Text(L10n.reminderLabel)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.liteCountSecondaryText)
                Spacer(minLength: 0)
                reminderNumberField($reminderDays, unit: L10n.reminderDayUnit, digits: 5, field: .days)
                reminderNumberField($reminderHours, unit: L10n.reminderHourUnit, digits: 2, field: .hours)
                reminderNumberField($reminderMinutes, unit: L10n.reminderMinuteUnit, digits: 2, field: .minutes)
            }
            .frame(height: 36)
            .padding(.horizontal, 10)
            .background(Color.liteCountElevated, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.liteCountSeparator, lineWidth: 1)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)

            if isPast {
                Text(L10n.pastHint)
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
            } else if let reminderError {
                Text(reminderError)
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 5)
            }

            Spacer(minLength: 0)

            countdownDisplay(at: now)
                .padding(.horizontal, 12)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                if editing != nil {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.red)
                            .frame(width: 36, height: 30)
                            .background(Color.red.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .help(L10n.delete)
                }
                Spacer()
                Button(action: onCancel) {
                    Text(L10n.cancel)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.liteCountPrimaryText)
                        .frame(width: 72, height: 30)
                        .background(Color.liteCountSeparator.opacity(0.35), in: Capsule())
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                Button(action: save) {
                    Text(L10n.save)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 30)
                        .background(canSave ? Color.liteCountBlue : Color.liteCountBlue.opacity(0.4), in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .onChange(of: name) { _, _ in controller.pinPanel() }
        .onChange(of: date) { _, _ in controller.pinPanel() }
        .onChange(of: icon) { _, _ in controller.pinPanel() }
        .onChange(of: colorHex) { _, _ in controller.pinPanel() }
        .onChange(of: reminderDays) { _, _ in controller.pinPanel() }
        .onChange(of: reminderHours) { _, _ in controller.pinPanel() }
        .onChange(of: reminderMinutes) { _, _ in controller.pinPanel() }
    }

    /// Targets must be in the future; checked live each second.
    private var isPast: Bool {
        date <= Date.now
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPast && reminderError == nil
    }

    private var reminderError: String? {
        guard (Int(reminderDays) ?? 0) <= 36_500,
              (Int(reminderHours) ?? 0) <= 23,
              (Int(reminderMinutes) ?? 0) <= 59
        else { return L10n.reminderRangeHint }
        guard reminderSeconds > 0 else { return nil }
        let fireDate = date.roundedToMinute.addingTimeInterval(-reminderSeconds)
        return fireDate > Date.now && fireDate < date.roundedToMinute ? nil : L10n.reminderTimeHint
    }

    private var reminderSeconds: TimeInterval {
        TimeInterval((Int(reminderDays) ?? 0) * 86_400 + (Int(reminderHours) ?? 0) * 3_600 + (Int(reminderMinutes) ?? 0) * 60)
    }

    private func save() {
        guard canSave else { return }
        let lead = reminderSeconds == 0 ? nil : "\(Int(reminderDays) ?? 0)天\(Int(reminderHours) ?? 0)小时\(Int(reminderMinutes) ?? 0)分钟"
        onSave(name, date.roundedToMinute, icon, colorHex, lead)
    }

    private func countdownDisplay(at now: Date) -> some View {
        let remaining = remainingText(until: date, from: now)
        return HStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.system(size: 20, weight: .medium))
            Text(remaining ?? L10n.expired)
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(remaining == nil ? Color.liteCountSecondaryText : colorHex.color)
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(colorHex.color.opacity(0.07), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(colorHex.color.opacity(0.15), lineWidth: 1)
        }
    }

    private var nameField: some View {
        HStack(spacing: 8) {
            PopoverField(popoverSize: NSSize(width: 360, height: 400)) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(colorHex.color, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .help(L10n.chooseIcon)
            } popoverContent: {
                IconPickerPopoverView(icon: $icon, colorHex: $colorHex)
            }
            .frame(width: 32, height: 32)
            TextField(L10n.namePlaceholder, text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .tint(Color.liteCountBlue)
        }
        .frame(height: 40)
        .padding(.horizontal, 6)
        .background(Color.liteCountElevated, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(Color.liteCountSeparator, lineWidth: 1)
        }
    }

    private func pickerField(_ text: String, symbol: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.liteCountSecondaryText)
            Text(text)
                .font(.system(size: 13))
                .monospacedDigit()
                .foregroundStyle(Color.primary)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .background(Color.liteCountElevated, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(Color.liteCountSeparator, lineWidth: 1)
        }
    }

    private func reminderNumberField(_ value: Binding<String>, unit: String, digits: Int, field: ReminderUnit) -> some View {
        let numeric = Binding<String>(
            get: { value.wrappedValue },
            set: { value.wrappedValue = String($0.filter { $0.isASCII && $0.isNumber }.prefix(digits)) }
        )
        return HStack(spacing: 4) {
            TextField("0", text: numeric)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .tint(Color.liteCountPrimaryText)
                .focused($focusedReminderUnit, equals: field)
                .frame(width: 38, height: 26)
                .padding(.trailing, 4)
                .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.liteCountSeparator.opacity(focusedReminderUnit == field ? 1 : 0.8), lineWidth: focusedReminderUnit == field ? 1.5 : 1)
                }
            Text(unit)
                .font(.system(size: 12))
                .foregroundStyle(Color.liteCountSecondaryText)
                .frame(width: 14, alignment: .leading)
        }
        .frame(width: 64)
        .accessibilityElement(children: .combine)
    }

}

private struct IconPickerPopoverView: View {
    @Binding var icon: String
    @Binding var colorHex: String
    @State private var iconSelectionReadyAt = Date.distantPast

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.chooseColor)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
                .padding(.bottom, 8)
            colorRow
                .padding(.bottom, 16)
            Text(L10n.chooseIcon)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
                .padding(.bottom, 8)
            ScrollView(.vertical) {
                iconGrid
                    .padding(.bottom, 4)
            }
        }
        .padding(12)
        .frame(width: 360, height: 400)
        .onAppear { iconSelectionReadyAt = Date.now.addingTimeInterval(0.45) }
    }

    private var colorRow: some View {
        HStack(spacing: 8) {
            ForEach(IconPalette.hexColors, id: \.self) { hex in
                let isSelected = hex == colorHex
                Button {
                    colorHex = hex
                } label: {
                    Circle()
                        .fill(hex.color)
                        .frame(width: 22, height: 22)
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.primary.opacity(0.65) : .clear, lineWidth: 1.5)
                                .padding(-3)
                        }
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    private var iconGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 6, verticalSpacing: 6) {
            ForEach(iconRows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { symbol in
                        iconCell(symbol)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var iconRows: [[String]] {
        stride(from: 0, to: IconCatalog.symbols.count, by: 7).map { start in
            Array(IconCatalog.symbols[start..<min(start + 7, IconCatalog.symbols.count)])
        }
    }

    private func iconCell(_ symbol: String) -> some View {
        let selected = symbol == icon
        return Button {
            guard Date.now >= iconSelectionReadyAt else { return }
            icon = symbol
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(selected ? .white : Color.liteCountSecondaryText)
                .frame(width: 42, height: 42)
                .background(
                    selected ? colorHex.color : Color.liteCountSeparator.opacity(0.22),
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Single-line text that ping-pong scrolls while hovered when it overflows,
/// so long item names stay fully readable without widening the row.
struct MarqueeText: View {
    let text: String
    var font: Font = .system(size: 13, weight: .medium)

    @State private var hovering = false
    @State private var contentWidth: CGFloat = 0
    private let tailGap: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let overflow = max(0, contentWidth - geo.size.width)
            Text(text)
                .font(font)
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .fixedSize()
                .background {
                    GeometryReader { inner in
                        Color.clear.preference(key: MarqueeContentWidthKey.self, value: inner.size.width)
                    }
                }
                .onPreferenceChange(MarqueeContentWidthKey.self) { contentWidth = $0 }
                .offset(x: hovering && overflow > 1 ? -(overflow + tailGap) : 0)
                .animation(
                    hovering && overflow > 1
                        ? .linear(duration: max(2.5, Double(overflow + tailGap) / 40)).repeatForever(autoreverses: true)
                        : .easeOut(duration: 0.2),
                    value: hovering
                )
        }
        .frame(height: 18, alignment: .leading)
        // Clip to the row's text area so the unhovered state never overlaps the countdown column.
        .clipped()
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }
}

private struct MarqueeContentWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct LiteCountHeaderHourglass: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        path.move(to: point(0.33, 0.70))
        path.addLine(to: point(0.67, 0.70))
        path.move(to: point(0.33, 0.30))
        path.addLine(to: point(0.67, 0.30))
        path.move(to: point(0.37, 0.68))
        path.addLine(to: point(0.37, 0.61))
        path.addLine(to: point(0.50, 0.50))
        path.addLine(to: point(0.63, 0.61))
        path.addLine(to: point(0.63, 0.68))
        path.move(to: point(0.37, 0.32))
        path.addLine(to: point(0.37, 0.39))
        path.addLine(to: point(0.50, 0.50))
        path.addLine(to: point(0.63, 0.39))
        path.addLine(to: point(0.63, 0.32))
        return path
    }
}

private struct HeaderButtonStyle: ButtonStyle {
    var hoverColor: Color = .primary

    func makeBody(configuration: Configuration) -> some View {
        HeaderButtonBody(configuration: configuration, hoverColor: hoverColor)
    }

    private struct HeaderButtonBody: View {
        let configuration: Configuration
        let hoverColor: Color
        @State private var hovering = false

        var body: some View {
            configuration.label
                .symbolRenderingMode(.monochrome)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 28, height: 28)
                .background(
                    hoverColor.opacity(configuration.isPressed ? 0.12 : hovering ? 0.08 : 0),
                    in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                )
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
        }
    }
}

private struct FastHelpModifier: ViewModifier {
    let text: String
    let horizontalOffset: CGFloat

    @State private var isPresented = false
    @State private var hoverToken = UUID()

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(text)
            .onHover { hovering in
                let token = UUID()
                hoverToken = token
                if hovering {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                        guard hoverToken == token else { return }
                        isPresented = true
                    }
                } else {
                    isPresented = false
                }
            }
            .overlay(alignment: .bottom) {
                if isPresented {
                    Text(text)
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(Color.liteCountSeparator, lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                        .offset(x: horizontalOffset, y: 28)
                        .allowsHitTesting(false)
                }
            }
            .zIndex(isPresented ? 20 : 0)
    }
}

private extension View {
    func fastHelp(_ text: String, horizontalOffset: CGFloat = 0) -> some View {
        modifier(FastHelpModifier(text: text, horizontalOffset: horizontalOffset))
    }
}
