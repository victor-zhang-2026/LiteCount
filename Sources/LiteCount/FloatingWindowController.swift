import AppKit
import SwiftUI

extension Notification.Name {
    static let liteCountPanelWillClose = Notification.Name("LiteCountPanelWillClose")
    static let liteCountPanelDidOpen = Notification.Name("LiteCountPanelDidOpen")
}

@MainActor
final class FloatingWindowController: NSObject, NSWindowDelegate {
    private let store: CountdownStore
    private let defaults: UserDefaults
    private let floatingPlacement: FloatingPlacement
    private var draggingTrigger = false
    var triggerPanel: FloatingPanel!
    var listPanel: FloatingPanel!
    private var openWorkItem: DispatchWorkItem?
    private var closeWorkItem: DispatchWorkItem?
    private var expiryWorkItem: DispatchWorkItem?
    private var isTriggerHovered = false
    private var isListHovered = false
    private var isPinned = false
    private var mouseMonitor: Any?
    private var outsideClickMonitor: Any?
    private var isAppearanceTransitioning = false
    private var isConfirmationActive = false
    private var aboutWindowController: AboutWindowController?
    private(set) var isOpen = false
    private(set) var isPanelLocked = false

    // The visible ball remains 42 pt; the extra transparent space prevents its circular shadow from clipping.
    private let triggerSize = NSSize(width: 48, height: 48)
    private var isEditorVisible = false
    private var panelSize: NSSize {
        NSSize(width: 360, height: isEditorVisible ? 480 : 352)
    }
    private let triggerScreenMargin: CGFloat = 8
    private let panelScreenMargin: CGFloat = 12
    private let triggerPanelGap: CGFloat = 8
    private let panelTransitionDuration: TimeInterval = 0.12
    // Some conferencing speaker overlays sit above the screen-saver level. Use the
    // system's high assistive-overlay level without entering cursor-reserved levels.
    static let alwaysOnTopLevel = NSWindow.Level(
        rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow))
    )

    init(store: CountdownStore, defaults: UserDefaults = .standard) {
        self.store = store
        self.defaults = defaults
        self.floatingPlacement = FloatingPlacement(defaults: defaults)
        super.init()
        // Pinning is deliberately session-only. Clear preferences left by earlier prototype builds.
        defaults.removeObject(forKey: "panelLocked")
        configurePanels()
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        store.onCountChanged = { [weak self] _ in
            self?.refreshTriggerCount()
        }
        refreshTriggerCount()
    }

    func showTrigger() {
        floatingPlacement.restore(triggerPanel, fallback: savedTriggerOrigin())
        triggerPanel.orderFrontRegardless()
        refreshTriggerCount()
    }

    func togglePanel() {
        isOpen ? dismissPanel() : openPanel(activate: true)
    }

    func dismissPanel() {
        if isPanelLocked {
            isPanelLocked = false
        }
        isPinned = false
        closePanel()
    }

    func openPinned() {
        isPinned = true
        openPanel(activate: true)
    }

    func pinPanel() {
        guard isOpen else { return }
        isPinned = true
        cancelClose()
    }

    func setEditorVisible(_ visible: Bool) {
        guard isEditorVisible != visible else { return }
        let currentTop = listPanel.frame.maxY
        isEditorVisible = visible
        if isOpen { positionListPanel(preferredTopY: currentTop) }
    }

    @discardableResult
    func togglePanelLock() -> Bool {
        isPanelLocked.toggle()
        if isPanelLocked {
            isPinned = true
            cancelClose()
        } else if !isTriggerHovered && !isListHovered {
            scheduleClose()
        }
        return isPanelLocked
    }

    func scheduleOpen() {
        isTriggerHovered = true
        cancelClose()
        guard !isOpen, !draggingTrigger else { return }
        openWorkItem?.cancel()
        openPanel(activate: true)
    }

    func triggerExited() {
        isTriggerHovered = false
        openWorkItem?.cancel()
        scheduleClose()
    }

    func listHoverChanged(_ hovering: Bool) {
        isListHovered = hovering
        hovering ? cancelClose() : scheduleClose()
    }

    func moveTrigger(to proposed: NSPoint, ended: Bool) {
        draggingTrigger = !ended
        openWorkItem?.cancel(); cancelClose()
        triggerPanel.setFrameOrigin(proposed)
        guard ended else { return }

        let proposedFrame = NSRect(origin: proposed, size: triggerSize)
        guard let screen = screenContaining(NSEvent.mouseLocation)
            ?? screenBestMatching(proposedFrame)
            ?? NSScreen.main else { return }
        let settled = constrainedTriggerOrigin(proposed, to: screen)
        triggerPanel.setFrameOrigin(settled)
        defaults.set(Double(settled.x), forKey: "triggerX")
        defaults.set(Double(settled.y), forKey: "triggerY")
        floatingPlacement.remember(triggerPanel)
        if isOpen { positionListPanel() }
    }

    @objc private func screensChanged() {
        floatingPlacement.afterScreenChange { [weak self] in
            guard let self, !self.draggingTrigger else { return }
            self.floatingPlacement.restore(self.triggerPanel, fallback: self.savedTriggerOrigin())
            if self.isOpen { self.positionListPanel() }
            self.triggerPanel.orderFrontRegardless()
        }
    }

    func quit() { NSApplication.shared.terminate(nil) }

    func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.present()
    }

    func refreshAbout() {
        aboutWindowController?.refresh()
    }

    func setConfirmationActive(_ active: Bool) {
        isConfirmationActive = active
        if active { cancelClose() }
    }

    func transitionAppearance(_ change: @escaping @MainActor () -> Void) {
        guard !isAppearanceTransitioning, let contentView = listPanel.contentView else { return }
        let bounds = contentView.bounds
        guard bounds.width > 0, bounds.height > 0, let oldImage = snapshot(of: contentView) else {
            change()
            return
        }

        let oldSnapshot = NSImageView(frame: bounds)
        oldSnapshot.image = oldImage
        oldSnapshot.imageScaling = .scaleAxesIndependently
        contentView.addSubview(oldSnapshot)

        isAppearanceTransitioning = true
        change()

        DispatchQueue.main.async { [weak self, weak oldSnapshot] in
            guard let self, let oldSnapshot else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.26
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                oldSnapshot.animator().alphaValue = 0
            }, completionHandler: {
                Task { @MainActor in
                    oldSnapshot.removeFromSuperview()
                    self.isAppearanceTransitioning = false
                }
            })
        }
    }

    private func snapshot(of view: NSView) -> NSImage? {
        let bounds = view.bounds
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        view.cacheDisplay(in: bounds, to: bitmap)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmap)
        return image
    }

    private func configurePanels() {
        triggerPanel = FloatingPanel(
            contentRect: NSRect(origin: .zero, size: triggerSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        prepare(triggerPanel)
        triggerPanel.becomesKeyOnlyIfNeeded = true
        triggerPanel.hasShadow = false
        let triggerView = FloatingBallView(controller: self)
        triggerView.totalCount = store.upcomingCount(at: .now)
        triggerView.wantsLayer = true
        triggerView.layer?.backgroundColor = NSColor.clear.cgColor
        triggerView.layer?.isOpaque = false
        triggerPanel.contentView = triggerView

        listPanel = FloatingPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        prepare(listPanel)
        listPanel.hasShadow = true
        listPanel.delegate = self
        listPanel.contentView = NSHostingView(rootView: CountdownListView(store: store, controller: self))
        mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }
            if event.window === self.listPanel {
                self.isPinned = true
                if event.type == .leftMouseDown, let editor = self.listPanel.firstResponder as? NSTextView {
                    let pointInEditor = editor.convert(event.locationInWindow, from: nil)
                    if !editor.bounds.contains(pointInEditor) {
                        self.listPanel.makeFirstResponder(nil)
                    }
                }
            }
            return event
        }
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPinned, !self.isPanelLocked, !self.isConfirmationActive else { return }
                self.listPanel.makeFirstResponder(nil)
                self.dismissPanel()
            }
        }
    }

    private func prepare(_ panel: NSPanel) {
        panel.level = Self.alwaysOnTopLevel
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.animationBehavior = .none
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
    }

    private func openPanel(activate: Bool) {
        openWorkItem?.cancel()
        isOpen = true
        positionListPanel()
        listPanel.alphaValue = 0
        listPanel.orderFrontRegardless()
        if activate {
            NSApplication.shared.activate(ignoringOtherApps: true)
            listPanel.makeKey()
            listPanel.makeFirstResponder(nil)
            NotificationCenter.default.post(name: .liteCountPanelDidOpen, object: nil)
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = panelTransitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            listPanel.animator().alphaValue = 1
        }
    }

    private func closePanel() {
        openWorkItem?.cancel()
        closeWorkItem?.cancel()
        NotificationCenter.default.post(name: .liteCountPanelWillClose, object: nil)
        listPanel.makeFirstResponder(nil)
        isOpen = false
        refreshTriggerCount()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = panelTransitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            listPanel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                guard let self, !self.isOpen else { return }
                self.listPanel.orderOut(nil)
                self.listPanel.alphaValue = 1
            }
        })
    }

    private func updateTriggerCount(_ count: Int) {
        guard let triggerView = triggerPanel.contentView as? FloatingBallView else { return }
        triggerView.totalCount = count
        triggerView.displayIfNeeded()
    }

    private func refreshTriggerCount() {
        expiryWorkItem?.cancel()
        let now = Date.now
        updateTriggerCount(store.upcomingCount(at: now))
        guard let nextExpiry = store.upcoming(at: now).first?.targetDate else { return }
        let work = DispatchWorkItem { [weak self] in self?.refreshTriggerCount() }
        expiryWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0, nextExpiry.timeIntervalSince(now)), execute: work)
    }

    private func scheduleClose() {
        cancelClose()
        let work = DispatchWorkItem { [weak self] in
            guard let self, !self.draggingTrigger, !self.isConfirmationActive, !self.isPanelLocked, !self.isPinned, !self.isTriggerHovered, !self.isListHovered else { return }
            self.closePanel()
        }
        closeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    private func cancelClose() {
        closeWorkItem?.cancel()
        closeWorkItem = nil
    }

    private func positionListPanel(preferredTopY: CGFloat? = nil) {
        guard let screen = screenContainingTrigger() ?? NSScreen.main else { return }
        let visible = screen.visibleFrame
        let trigger = triggerPanel.frame
        let spaceOnLeft = trigger.minX - visible.minX - panelScreenMargin
        let spaceOnRight = visible.maxX - trigger.maxX - panelScreenMargin
        let leftX = trigger.minX - panelSize.width - triggerPanelGap
        let rightX = trigger.maxX + triggerPanelGap
        let leftFits = leftX >= visible.minX + panelScreenMargin
        let rightFits = rightX + panelSize.width <= visible.maxX - panelScreenMargin
        let proposedX: CGFloat
        if leftFits && (!rightFits || spaceOnLeft >= spaceOnRight) {
            proposedX = leftX
        } else if rightFits {
            proposedX = rightX
        } else {
            proposedX = leftX
        }
        let x = min(
            max(proposedX, visible.minX + panelScreenMargin),
            visible.maxX - panelSize.width - panelScreenMargin
        )
        let centeredY = preferredTopY.map { $0 - panelSize.height }
            ?? trigger.midY - panelSize.height / 2
        let y = min(
            max(centeredY, visible.minY + panelScreenMargin),
            visible.maxY - panelSize.height - panelScreenMargin
        )
        listPanel.setFrame(NSRect(x: x, y: y, width: panelSize.width, height: panelSize.height), display: true)
    }

    private func screenContainingTrigger() -> NSScreen? {
        let center = NSPoint(x: triggerPanel.frame.midX, y: triggerPanel.frame.midY)
        return screenContaining(center) ?? screenBestMatching(triggerPanel.frame)
    }

    private func screenContaining(_ point: NSPoint) -> NSScreen? {
        NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }

    private func screenBestMatching(_ windowFrame: NSRect) -> NSScreen? {
        let screensByIntersection = NSScreen.screens.map { screen in
            let intersection = windowFrame.intersection(screen.frame)
            return (screen: screen, area: intersection.width * intersection.height)
        }
        if let best = screensByIntersection.max(by: { $0.area < $1.area }), best.area > 0 {
            return best.screen
        }

        let center = NSPoint(x: windowFrame.midX, y: windowFrame.midY)
        return NSScreen.screens.min { lhs, rhs in
            squaredDistance(from: center, to: lhs.frame) < squaredDistance(from: center, to: rhs.frame)
        }
    }

    private func squaredDistance(from point: NSPoint, to rect: NSRect) -> CGFloat {
        let closestX = min(max(point.x, rect.minX), rect.maxX)
        let closestY = min(max(point.y, rect.minY), rect.maxY)
        let dx = point.x - closestX
        let dy = point.y - closestY
        return dx * dx + dy * dy
    }

    private func constrainedTriggerOrigin(_ origin: NSPoint, to screen: NSScreen) -> NSPoint {
        let frame = screen.visibleFrame
        return NSPoint(
            x: min(
                max(origin.x, frame.minX + triggerScreenMargin),
                frame.maxX - triggerSize.width - triggerScreenMargin
            ),
            y: min(
                max(origin.y, frame.minY + triggerScreenMargin),
                frame.maxY - triggerSize.height - triggerScreenMargin
            )
        )
    }

    private func savedTriggerOrigin() -> NSPoint {
        guard let screen = NSScreen.main else { return NSPoint(x: 800, y: 300) }
        let frame = screen.visibleFrame
        if defaults.object(forKey: "triggerX") != nil {
            let x = CGFloat(defaults.double(forKey: "triggerX"))
            let y = CGFloat(defaults.double(forKey: "triggerY"))
            let savedOrigin = NSPoint(x: x, y: y)
            let savedFrame = NSRect(origin: savedOrigin, size: triggerSize)
            let targetScreen = screenBestMatching(savedFrame) ?? screen
            return constrainedTriggerOrigin(savedOrigin, to: targetScreen)
        }
        return NSPoint(x: frame.maxX - triggerSize.width - 10, y: frame.midY - triggerSize.height / 2)
    }
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
