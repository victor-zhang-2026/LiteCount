import AppKit
import SwiftUI

// MARK: - Locale-aware formatting

enum AppFormat {
    static func locale() -> Locale {
        Locale(identifier: L10n.isChinese ? "zh_CN" : "en_US")
    }

    static func dateTimeText(_ date: Date) -> String {
        if !L10n.isChinese {
            let formatter = DateFormatter()
            formatter.locale = locale()
            formatter.dateFormat = "MMM d, yyyy HH:mm"
            return formatter.string(from: date)
        }
        return date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale()))
    }

    static func dateText(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted).locale(locale()))
    }

    static func timeText(_ date: Date) -> String {
        if !L10n.isChinese {
            let formatter = DateFormatter()
            formatter.locale = locale()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return date.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale()))
    }
}

// MARK: - Popover field

/// A styled field that presents a transient NSPopover when clicked.
/// Popovers close via the shared `.liteCountClosePopovers` notification.
struct PopoverField<Label: View, Content: View>: View {
    let popoverSize: NSSize
    @ViewBuilder let label: Label
    @ViewBuilder let popoverContent: Content
    @State private var coordinator = Coordinator()

    @MainActor
    final class Coordinator: NSObject, NSPopoverDelegate {
        var popover: NSPopover?

        override init() {
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(closeRequested),
                name: .liteCountClosePopovers,
                object: nil
            )
        }

        @objc private func closeRequested() {
            popover?.performClose(nil)
        }

        func present(content: Content, size: NSSize, from anchor: NSView) {
            if let popover, popover.isShown {
                popover.performClose(nil)
                return
            }
            let popover = NSPopover()
            popover.behavior = .transient
            popover.animates = false
            popover.contentViewController = NSHostingController(rootView: content)
            popover.contentSize = size
            popover.delegate = self
            self.popover = popover
            popover.show(relativeTo: anchor.bounds, of: anchor, preferredEdge: .maxY)
        }

        func popoverDidClose(_ notification: Notification) {
            popover = nil
        }
    }

    var body: some View {
        ZStack {
            label
            AnchorView { anchor in
                coordinator.present(content: popoverContent, size: popoverSize, from: anchor)
            }
        }
    }

    struct AnchorView: NSViewRepresentable {
        let onTap: (NSView) -> Void

        final class AnchorNSView: NSView {
            var onTap: ((NSView) -> Void)?
            override func mouseDown(with event: NSEvent) { onTap?(self) }
        }

        func makeNSView(context: Context) -> AnchorNSView {
            let view = AnchorNSView()
            view.onTap = { onTap($0) }
            return view
        }

        func updateNSView(_ view: AnchorNSView, context: Context) {
            view.onTap = { onTap($0) }
        }
    }
}

// MARK: - Combined date & time popover

struct DateTimePickerPopoverView: View {
    @Binding var date: Date
    @State private var displayedMonth: Date

    init(date: Binding<Date>) {
        _date = date
        _displayedMonth = State(initialValue: date.wrappedValue.startOfMonth)
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppFormat.locale()
        return calendar
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.year().month(.wide).locale(AppFormat.locale()))
    }

    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }

    @AppStorage("appAppearance") private var appearanceRawValue = AppearanceMode.light.rawValue
    private var systemAppearance: ColorScheme {
        AppearanceMode(rawValue: appearanceRawValue)?.colorScheme ?? .light
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                navButton("chevron.left") {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                navButton("chevron.right") {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            }

            weekdayHeader

            dayGrid

            Rectangle()
                .fill(Color.liteCountSeparator.opacity(0.4))
                .frame(height: 0.5)

            HStack(spacing: 10) {
                timeColumn(header: L10n.hourColumn, range: 0..<24, selected: hour) { newHour in
                    date = calendar.date(bySettingHour: newHour, minute: minute, second: 0, of: date) ?? date
                }
                Rectangle().fill(Color.liteCountSeparator.opacity(0.4)).frame(width: 0.5)
                timeColumn(header: L10n.minuteColumn, range: 0..<60, selected: minute) { newMinute in
                    date = calendar.date(bySettingHour: hour, minute: newMinute, second: 0, of: date) ?? date
                }
            }
            .frame(height: 122)

            HStack {
                Spacer()
                Button(L10n.done) {
                    NotificationCenter.default.post(name: .liteCountClosePopovers, object: nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.liteCountBlue)
            }
        }
        .padding(12)
        .frame(width: 252, height: 444)
        .preferredColorScheme(systemAppearance)
    }

    private func navButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.liteCountSecondaryText)
                .frame(width: 26, height: 26)
                .background(Color.liteCountSeparator.opacity(0.001), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var weekdayHeader: some View {
        let symbols = calendar.shortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        let ordered = Array(symbols[offset...] + symbols[..<offset])
        return HStack(spacing: 0) {
            ForEach(ordered, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.liteCountSecondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        // Eager Grid (not LazyVGrid) so every day cell renders reliably, including offscreen capture.
        Grid(alignment: .center, horizontalSpacing: 2, verticalSpacing: 2) {
            ForEach(dayCellRows, id: \.self) { row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                        if let dayNumber = cell {
                            dayButton(dayNumber)
                        } else {
                            Color.clear.frame(height: 28)
                        }
                    }
                }
            }
        }
    }

    private var dayCellRows: [[Int?]] {
        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0
        let firstWeekdayIndex = (Int(calendar.component(.weekday, from: displayedMonth.startOfMonth)) - calendar.firstWeekday + 7) % 7
        var cells: [Int?] = Array(repeating: nil, count: firstWeekdayIndex)
        cells.append(contentsOf: (1...daysInMonth).map { Optional($0) })
        while cells.count % 7 != 0 { cells.append(nil) }
        return stride(from: 0, to: cells.count, by: 7).map { start in
            Array(cells[start..<min(start + 7, cells.count)])
        }
    }

    private func dayButton(_ dayNumber: Int) -> some View {
        let dayDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: displayedMonth.startOfMonth) ?? displayedMonth
        let isSelected = calendar.isDate(dayDate, inSameDayAs: calendar.startOfDay(for: date))
        let isToday = calendar.isDate(dayDate, inSameDayAs: calendar.startOfDay(for: Date.now))

        return Button {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
            var dayComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
            dayComponents.hour = timeComponents.hour
            dayComponents.minute = timeComponents.minute
            date = calendar.date(from: dayComponents) ?? dayDate
        } label: {
            Text("\(dayNumber)")
                .font(.system(size: 12.5, weight: isToday ? .semibold : .regular, design: .rounded))
                .foregroundStyle(isSelected ? .white : (isToday ? Color.liteCountBlue : Color.primary))
                .frame(width: 28, height: 28)
                .background(
                    isSelected
                        ? Color.liteCountBlue
                        : Color.liteCountSeparator.opacity(0.001),
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .overlay {
                    if isToday && !isSelected {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.liteCountBlue.opacity(0.55), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func timeColumn(header: String, range: Range<Int>, selected: Int, onSelect: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 4) {
            Text(header)
                .font(.system(size: 11))
                .foregroundStyle(Color.liteCountSecondaryText)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(range, id: \.self) { value in
                            let isSelected = value == selected
                            Button {
                                onSelect(value)
                            } label: {
                                Text(String(format: "%02d", value))
                                    .font(.system(size: 12.5, weight: isSelected ? .semibold : .regular, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(isSelected ? .white : Color.primary)
                                    .frame(width: 64, height: 24)
                                    .background(
                                        isSelected ? Color.liteCountBlue : Color.liteCountSeparator.opacity(0.001),
                                        in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    )
                            }
                            .buttonStyle(.plain)
                            .id(value)
                        }
                    }
                    .padding(.vertical, 1)
                }
                .onAppear {
                    proxy.scrollTo(selected, anchor: .center)
                }
                .onChange(of: selected) { _, newValue in
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
}

extension Notification.Name {
    static let liteCountClosePopovers = Notification.Name("LiteCountClosePopovers")
}
