import AppKit
import SwiftUI

struct CountdownListView: View {
    @Bindable var store: CountdownStore
    let controller: FloatingWindowController

    @State private var showingEditor = false
    @State private var editingItem: CountdownItem?
    @State private var deleteCandidate: CountdownItem?
    @State private var languageVersion = UUID()
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
                        onSave: { name, date, icon, colorHex in
                            if let editingItem {
                                store.update(id: editingItem.id, name: name, targetDate: date, icon: icon, colorHex: colorHex)
                            } else {
                                store.add(name: name, targetDate: date, icon: icon, colorHex: colorHex)
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
                    listContent
                }
            }
            .id(languageVersion)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if deleteCandidate != nil {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.black.opacity(appearanceMode == .dark ? 0.48 : 0.24))
                deletionConfirmation
            }
        }
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
        HStack(spacing: 10) {
            Button {
                controller.showAbout()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.liteCountBlue)
                    Image(systemName: "hourglass").font(.system(size: 13, weight: .heavy)).foregroundStyle(.white)
                }
                .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .fastHelp(L10n.about)
            Text(L10n.appName)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
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

            Button {
                L10n.toggleLanguage()
                languageVersion = UUID()
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
        .padding(.horizontal, 16)
        .frame(height: 48)
        .zIndex(10)
    }

    private var listContent: some View {
        VStack(spacing: 0) {
            if store.items.isEmpty { emptyState }
            else { countdownScroll }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "hourglass")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.liteCountSecondaryText)
            Text(L10n.emptyTitle)
                .font(.system(size: 13, weight: .medium))
            Text(L10n.emptyHint)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
            Spacer()
        }
    }

    private var countdownScroll: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.sorted) { item in
                        CountdownRow(
                            item: item,
                            now: timeline.date,
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
            .contentShape(Rectangle())
            .onTapGesture { onEdit() }

            if let remaining {
                Text(remaining)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.primary)
            } else {
                Text(L10n.expired)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.liteCountSecondaryText)
            }

            HStack(spacing: 4) {
                Button(action: onEdit) {
                    RowActionIcon(systemName: "pencil", weight: .medium, hoverColor: .liteCountBlue)
                }
                .buttonStyle(.plain)
                .opacity(hovering ? 1 : 0)
                .allowsHitTesting(hovering)
                .accessibilityHidden(!hovering)
                .help(L10n.edit)

                Button(action: onDelete) {
                    RowActionIcon(systemName: "trash", weight: .medium, hoverColor: .red)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.red.opacity(0.78))
                .opacity(hovering ? 1 : 0)
                .allowsHitTesting(hovering)
                .accessibilityHidden(!hovering)
                .help(L10n.delete)
            }
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
        .onHover { hovering = $0 }
        .contextMenu {
            Button(L10n.edit, action: onEdit)
            Button(L10n.delete, role: .destructive, action: onDelete)
        }
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
    let controller: FloatingWindowController
    let editing: CountdownItem?
    let onSave: (String, Date, String, String) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var date: Date
    @State private var icon: String
    @State private var colorHex: String

    init(controller: FloatingWindowController, editing: CountdownItem?, onSave: @escaping (String, Date, String, String) -> Void, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.controller = controller
        self.editing = editing
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _name = State(initialValue: editing?.name ?? "")
        _date = State(initialValue: (editing?.targetDate ?? Date.now.addingTimeInterval(86_400)).roundedToMinute)
        _icon = State(initialValue: editing?.icon ?? IconCatalog.defaultSymbol)
        _colorHex = State(initialValue: editing?.colorHex ?? IconPalette.defaultHex)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            editorContent
        }
    }

    private var editorContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            nameField
                .padding(.horizontal, 12)
                .padding(.top, 12)

            HStack(spacing: 10) {
                Text(L10n.targetTime)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.liteCountSecondaryText)
                PopoverField(popoverSize: NSSize(width: 252, height: 444)) {
                    pickerField(AppFormat.dateTimeText(date), symbol: "calendar")
                } popoverContent: {
                    DateTimePickerPopoverView(date: $date)
                }
            }
            .frame(height: 36)
            .padding(.horizontal, 16)
            .padding(.top, 10)

            if isPast {
                Text(L10n.pastHint)
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
            }

            Text(L10n.chooseColor)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            colorRow
                .padding(.horizontal, 16)
                .padding(.top, 6)

            Text(L10n.chooseIcon)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            ScrollView {
                iconGrid
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            }

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
            .padding(.vertical, 14)
        }
        .onChange(of: name) { _, _ in controller.pinPanel() }
        .onChange(of: date) { _, _ in controller.pinPanel() }
        .onChange(of: icon) { _, _ in controller.pinPanel() }
        .onChange(of: colorHex) { _, _ in controller.pinPanel() }
    }

    /// Targets must be in the future; checked live each second.
    private var isPast: Bool {
        date <= Date.now
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPast
    }

    private func save() {
        guard canSave else { return }
        onSave(name, date.roundedToMinute, icon, colorHex)
    }

    private var nameField: some View {
        TextField(L10n.namePlaceholder, text: $name)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .tint(Color.liteCountBlue)
            .frame(height: 40)
            .padding(.horizontal, 13)
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

    private var colorRow: some View {
        HStack(spacing: 8) {
            ForEach(IconPalette.hexColors, id: \.self) { hex in
                let isSelected = hex == colorHex
                Button {
                    controller.pinPanel()
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
        // Eager Grid (not LazyVGrid) so all symbols render reliably, including offscreen capture.
        Grid(alignment: .center, horizontalSpacing: 6, verticalSpacing: 6) {
            ForEach(iconRows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { symbol in
                        iconCell(symbol)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var iconRows: [[String]] {
        stride(from: 0, to: IconCatalog.symbols.count, by: 7).map { start in
            Array(IconCatalog.symbols[start..<min(start + 7, IconCatalog.symbols.count)])
        }
    }

    private func iconCell(_ symbol: String) -> some View {
        let selected = symbol == icon
        return Button {
            controller.pinPanel()
            icon = symbol
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.liteCountSecondaryText)
                .frame(width: 30, height: 30)
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

private struct RowActionIcon: View {
    let systemName: String
    let weight: Font.Weight
    let hoverColor: Color
    @State private var hovering = false

    var body: some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: 13, weight: weight))
            .frame(width: 24, height: 24)
            .background(
                hoverColor.opacity(hovering ? 0.12 : 0),
                in: RoundedRectangle(cornerRadius: 5, style: .continuous)
            )
            .contentShape(Rectangle())
            .onHover { hovering = $0 }
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
