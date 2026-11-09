import AppKit

@MainActor
final class FloatingBallView: NSView {
    private weak var controller: FloatingWindowController?
    private var trackingAreaRef: NSTrackingArea?
    private var isHovering = false
    private var mouseDownPoint: NSPoint?
    private var dragStartOrigin: NSPoint?
    private var didDrag = false
    private let badgeView = TotalBadgeView(frame: .zero)
    var totalCount = 0 { didSet { updateBadge() } }

    init(controller: FloatingWindowController) {
        self.controller = controller
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.isOpaque = false
        addSubview(badgeView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isOpaque: Bool { false }
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateBadge()
    }

    private func updateBadge() {
        badgeView.count = totalCount
        badgeView.isHidden = totalCount == 0
        let size = badgeView.badgeSize
        badgeView.frame = NSRect(
            x: bounds.maxX - size.width - 1,
            y: bounds.maxY - size.height - 1,
            width: size.width,
            height: size.height
        )
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef { removeTrackingArea(trackingAreaRef) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingAreaRef = area
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        let outerInset: CGFloat = 3
        let outerCircle = NSBezierPath(ovalIn: bounds.insetBy(dx: outerInset, dy: outerInset))
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(isHovering ? 0.20 : 0.14)
        shadow.shadowBlurRadius = isHovering ? 5 : 4
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.setFill()
        outerCircle.fill()
        NSGraphicsContext.restoreGraphicsState()

        let innerInset: CGFloat = isHovering ? 6 : 7
        let circleRect = bounds.insetBy(dx: innerInset, dy: innerInset)
        let circle = NSBezierPath(ovalIn: circleRect)
        NSColor.liteCountBlueHover.setFill()
        circle.fill()

        drawHourglass(in: bounds)
    }

    private func drawHourglass(in bounds: NSRect) {
        let w = bounds.width, h = bounds.height
        let hourglass = NSBezierPath()
        hourglass.lineWidth = 3.0
        hourglass.lineCapStyle = .round
        hourglass.lineJoinStyle = .round
        NSColor.white.setStroke()

        // Top and bottom caps.
        hourglass.move(to: NSPoint(x: w * 0.33, y: h * 0.68))
        hourglass.line(to: NSPoint(x: w * 0.67, y: h * 0.68))
        hourglass.move(to: NSPoint(x: w * 0.33, y: h * 0.32))
        hourglass.line(to: NSPoint(x: w * 0.67, y: h * 0.32))

        // Upper chamber narrowing to the waist.
        hourglass.move(to: NSPoint(x: w * 0.37, y: h * 0.66))
        hourglass.line(to: NSPoint(x: w * 0.37, y: h * 0.60))
        hourglass.line(to: NSPoint(x: w * 0.50, y: h * 0.50))
        hourglass.line(to: NSPoint(x: w * 0.63, y: h * 0.60))
        hourglass.line(to: NSPoint(x: w * 0.63, y: h * 0.66))

        // Lower chamber widening from the waist.
        hourglass.move(to: NSPoint(x: w * 0.37, y: h * 0.34))
        hourglass.line(to: NSPoint(x: w * 0.37, y: h * 0.40))
        hourglass.line(to: NSPoint(x: w * 0.50, y: h * 0.50))
        hourglass.line(to: NSPoint(x: w * 0.63, y: h * 0.40))
        hourglass.line(to: NSPoint(x: w * 0.63, y: h * 0.34))

        hourglass.stroke()
    }

    override func mouseEntered(with event: NSEvent) {
        isHovering = true
        needsDisplay = true
        controller?.scheduleOpen()
    }

    override func mouseExited(with event: NSEvent) {
        isHovering = false
        needsDisplay = true
        controller?.triggerExited()
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownPoint = NSEvent.mouseLocation
        dragStartOrigin = window?.frame.origin
        didDrag = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = mouseDownPoint, let origin = dragStartOrigin else { return }
        let current = NSEvent.mouseLocation
        let dx = current.x - start.x, dy = current.y - start.y
        if !didDrag && hypot(dx, dy) <= 3 { return }
        didDrag = true
        controller?.moveTrigger(to: NSPoint(x: origin.x + dx, y: origin.y + dy), ended: false)
    }

    override func mouseUp(with event: NSEvent) {
        if didDrag, let start = mouseDownPoint, let origin = dragStartOrigin {
            let pointer = NSEvent.mouseLocation
            controller?.moveTrigger(to: NSPoint(x: origin.x + pointer.x - start.x, y: origin.y + pointer.y - start.y), ended: true)
        }
        else { controller?.openPinned() }
        mouseDownPoint = nil
        dragStartOrigin = nil
        didDrag = false
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        let quit = NSMenuItem(title: L10n.quit, action: #selector(quitApplication), keyEquivalent: "")
        quit.target = self
        menu.addItem(quit)
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    @objc private func quitApplication() { controller?.quit() }
}

@MainActor
private final class TotalBadgeView: NSView {
    var count = 0 { didSet { needsDisplay = true } }

    private var label: String { count > 99 ? "99+" : String(count) }
    private var attributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.systemFont(ofSize: label.count > 2 ? 8 : 10, weight: .bold),
            .foregroundColor: NSColor.white
        ]
    }

    var badgeSize: NSSize {
        NSSize(width: max(17, ceil((label as NSString).size(withAttributes: attributes).width) + 8), height: 17)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.isOpaque = false
        isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isOpaque: Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func draw(_ dirtyRect: NSRect) {
        let badge = NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2)
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.24)
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor(calibratedRed: 1, green: 0.23, blue: 0.19, alpha: 1).setFill()
        badge.fill()
        NSGraphicsContext.restoreGraphicsState()

        let labelSize = (label as NSString).size(withAttributes: attributes)
        (label as NSString).draw(
            at: NSPoint(x: bounds.midX - labelSize.width / 2, y: bounds.midY - labelSize.height / 2 + 1),
            withAttributes: attributes
        )
    }
}
