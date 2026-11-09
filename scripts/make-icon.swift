import AppKit

// Generates Support/LiteCount.iconset PNGs from the drawn brand artwork:
// blue squircle with the white line-drawn hourglass (same geometry as the floating ball).
let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let inset: CGFloat = 100
let rect = NSRect(x: inset, y: inset, width: CGFloat(size) - 2 * inset, height: CGFloat(size) - 2 * inset)
NSColor(calibratedRed: 9 / 255, green: 118 / 255, blue: 229 / 255, alpha: 1).setFill()
NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185).fill()

func pt(_ fx: CGFloat, _ fy: CGFloat) -> NSPoint {
    NSPoint(x: rect.minX + rect.width * fx, y: rect.minY + rect.height * fy)
}

let hourglass = NSBezierPath()
hourglass.lineWidth = 46
hourglass.lineCapStyle = .round
hourglass.lineJoinStyle = .round
NSColor.white.setStroke()

hourglass.move(to: pt(0.33, 0.70))
hourglass.line(to: pt(0.67, 0.70))
hourglass.move(to: pt(0.33, 0.30))
hourglass.line(to: pt(0.67, 0.30))

hourglass.move(to: pt(0.37, 0.68))
hourglass.line(to: pt(0.37, 0.61))
hourglass.line(to: pt(0.50, 0.50))
hourglass.line(to: pt(0.63, 0.61))
hourglass.line(to: pt(0.63, 0.68))

hourglass.move(to: pt(0.37, 0.32))
hourglass.line(to: pt(0.37, 0.39))
hourglass.line(to: pt(0.50, 0.50))
hourglass.line(to: pt(0.63, 0.39))
hourglass.line(to: pt(0.63, 0.32))

hourglass.stroke()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Failed to render icon")
}

let fileManager = FileManager.default
let iconsetURL = URL(fileURLWithPath: "Support/LiteCount.iconset")
try? fileManager.removeItem(at: iconsetURL)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let specs: [(Int, String)] = [
    (16, "icon_16x16"), (32, "icon_16x16@2x"),
    (32, "icon_32x32"), (64, "icon_32x32@2x"),
    (128, "icon_128x128"), (256, "icon_128x128@2x"),
    (256, "icon_256x256"), (512, "icon_256x256@2x"),
    (512, "icon_512x512"), (1024, "icon_512x512@2x")
]

for (pixel, name) in specs {
    let scaled = NSImage(size: NSSize(width: pixel, height: pixel), flipped: false) { _ in
        image.draw(in: NSRect(x: 0, y: 0, width: pixel, height: pixel))
        return true
    }
    guard let t = scaled.tiffRepresentation,
          let r = NSBitmapImageRep(data: t),
          let p = r.representation(using: .png, properties: [:]) else {
        fatalError("Failed to render \(name)")
    }
    try p.write(to: iconsetURL.appendingPathComponent("\(name).png"))
}

print("iconset written to \(iconsetURL.path)")
