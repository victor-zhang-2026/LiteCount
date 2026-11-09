import AppKit
import SwiftUI

/// Renders real app views with fictional, isolated data for documentation and marketing images.
/// Enabled with LITECOUNT_MARKETING_CAPTURE=1; writes PNGs to LITECOUNT_CAPTURE_DIR.
@MainActor
enum MarketingCapture {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["LITECOUNT_MARKETING_CAPTURE"] == "1"
    }

    static func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = CaptureDelegate()
        app.run()
    }
}

@MainActor
final class CaptureDelegate: NSObject, NSApplicationDelegate {
    private var store: CountdownStore!
    private var controller: FloatingWindowController!
    private var output = URL(fileURLWithPath: "marketing/captures")
    private var editorWindow: NSWindow?
    private var pickerWindow: NSWindow?
    private var originalAppearance: String?
    private var steps: [(delay: TimeInterval, action: () -> Void)] = []
    private var stepIndex = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        let env = ProcessInfo.processInfo.environment
        output = URL(fileURLWithPath: env["LITECOUNT_CAPTURE_DIR"] ?? "marketing/captures", isDirectory: true)
        try? FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let isolatedDefaults = UserDefaults(suiteName: "app.litecount.marketing")!

        // Remember the pre-capture appearance so it can be restored exactly.
        originalAppearance = UserDefaults.standard.string(forKey: "appAppearance")

        store = CountdownStore(fileURL: output.appendingPathComponent("isolated-data/items.json"))
        store.deleteAllForCapture()
        seedItems()

        controller = FloatingWindowController(store: store, defaults: isolatedDefaults)
        controller.showTrigger()
        controller.openPinned()

        steps = [
            // Force light for the base captures so results are deterministic.
            (delay: 0.3, action: { UserDefaults.standard.set("light", forKey: "appAppearance") }),
            (delay: 0.9, action: { self.captureView(self.controller.listPanel.contentView, "panel-list.png") }),
            (delay: 0.3, action: { self.captureView(self.controller.triggerPanel.contentView, "trigger.png") }),
            (delay: 0.3, action: { self.openEditorWindow() }),
            (delay: 1.0, action: {
                self.captureView(self.editorWindow?.contentView, "editor.png")
                self.editorWindow?.orderOut(nil)
            }),
            (delay: 0.3, action: { self.openPickerWindow() }),
            (delay: 1.0, action: {
                self.captureView(self.pickerWindow?.contentView, "date-picker.png")
                self.pickerWindow?.orderOut(nil)
            }),
            (delay: 0.3, action: { UserDefaults.standard.set("dark", forKey: "appAppearance") }),
            (delay: 0.9, action: { self.captureView(self.controller.listPanel.contentView, "panel-list-dark.png") }),
            (delay: 0.3, action: {
                // Restore the exact pre-capture value, including "was unset".
                if let original = self.originalAppearance {
                    UserDefaults.standard.set(original, forKey: "appAppearance")
                } else {
                    UserDefaults.standard.removeObject(forKey: "appAppearance")
                }
                print("MARKETING_CAPTURE_DONE")
                NSApplication.shared.terminate(nil)
            })
        ]
        runNextStep()
    }

    private func runNextStep() {
        guard stepIndex < steps.count else { return }
        let step = steps[stepIndex]
        stepIndex += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + step.delay) { [self] in
            step.action()
            runNextStep()
        }
    }

    private func seedItems() {
        let now = Date.now
        let items: [(String, TimeInterval, String, String)] = [
            ("产品发布会", 2 * 3600 + 1320, "rocket", "#FF3B30"),
            ("出差杭州", 3 * 86400 + 5040, "airplane", "#0A76E5"),
            ("版本上线", 9 * 86400 + 9000, "laptopcomputer", "#5E5CE6"),
            ("朋友生日", 16 * 86400 + 3780, "birthday.cake", "#FF2D92"),
            ("婚礼纪念日", 34 * 86400 + 12600, "heart", "#AF52DE"),
            ("马拉松比赛", 58 * 86400 + 28800, "figure.run", "#34C759"),
            ("旅行出发", 96 * 86400 + 36000, "umbrella", "#FF9500"),
            ("新年计划", 364 * 86400 + 43200, "flag.checkered", "#30B0C7")
        ]
        for (name, offset, icon, colorHex) in items {
            store.add(name: name, targetDate: now.addingTimeInterval(offset), icon: icon, colorHex: colorHex)
        }
    }

    private func openEditorWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 470),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = FloatingWindowController.alwaysOnTopLevel
        window.backgroundColor = .clear
        window.isOpaque = false
        let editor = CountdownEditor(
            controller: controller,
            editing: nil,
            onSave: { _, _, _, _ in },
            onDelete: {},
            onCancel: {}
        )
        let content = ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
            editor
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        window.contentView = NSHostingView(rootView: content)
        window.center()
        window.orderFrontRegardless()
        editorWindow = window
    }

    private func openPickerWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 252, height: 444),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = FloatingWindowController.alwaysOnTopLevel
        window.backgroundColor = .clear
        window.isOpaque = false
        let picker = DateTimePickerPopoverView(date: .constant(Date.now.addingTimeInterval(3 * 86400 + 5400).roundedToMinute))
        let content = picker.background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        window.contentView = NSHostingView(rootView: content)
        window.center()
        window.orderFrontRegardless()
        pickerWindow = window
    }

    private func captureView(_ view: NSView?, _ name: String) {
        guard let view else {
            print("SKIP \(name): no view")
            return
        }
        view.layoutSubtreeIfNeeded()
        view.displayIfNeeded()
        let bounds = view.bounds
        let scale: CGFloat = 2
        guard bounds.width > 0, bounds.height > 0 else {
            print("SKIP \(name): empty bounds \(bounds)")
            return
        }
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(bounds.width * scale),
            pixelsHigh: Int(bounds.height * scale),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        bitmap.size = bounds.size
        view.cacheDisplay(in: bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            print("SKIP \(name): no png")
            return
        }
        do {
            try data.write(to: output.appendingPathComponent(name))
            print("captured \(name)")
        } catch {
            print("SKIP \(name): \(error)")
        }
    }
}
