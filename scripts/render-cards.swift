import AppKit
import SwiftUI

// Renders LiteCount v1.0.0 marketing cards from the real app screenshots.
// Run from the project root:  swift scripts/render-cards.swift

struct Spec {
    let name: String
    let size: CGSize
    let title: String
    let subtitle: String
    let image: String?
    let footer: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let out = root.appendingPathComponent("marketing/v1.0.0")
let captures = root.appendingPathComponent("marketing/captures")

let brandFooter = "LiteCount · macOS"

let specs: [Spec] = [
    // 公众号
    Spec(name: "wechat/cover.png", size: CGSize(width: 900, height: 383),
         title: "LiteCount", subtitle: "轻量桌面倒计时 · 随时看到重要时刻", image: "panel-list", footer: brandFooter),
    Spec(name: "wechat/cover-small.png", size: CGSize(width: 200, height: 200),
         title: "", subtitle: "", image: "panel-list", footer: ""),

    // 小红书 1080×1440
    Spec(name: "xiaohongshu/xhs-1.png", size: CGSize(width: 1080, height: 1440),
         title: "重要的日子，值得被看见", subtitle: "LiteCount · 轻量桌面倒计时", image: "panel-list", footer: brandFooter),
    Spec(name: "xiaohongshu/xhs-2.png", size: CGSize(width: 1080, height: 1440),
         title: "剩余天·时·分·秒\n实时跳动", subtitle: "悬浮球悬停即展开，近到远自动排序", image: "panel-list", footer: brandFooter),
    Spec(name: "xiaohongshu/xhs-3.png", size: CGSize(width: 1080, height: 1440),
         title: "三步创建一个倒计时", subtitle: "名称 · 目标时间 · 图标颜色", image: "editor", footer: brandFooter),
    Spec(name: "xiaohongshu/xhs-4.png", size: CGSize(width: 1080, height: 1440),
         title: "日期时间，一起选", subtitle: "日历与时分同屏，选完即存", image: "date-picker", footer: brandFooter),
    Spec(name: "xiaohongshu/xhs-5.png", size: CGSize(width: 1080, height: 1440),
         title: "图标和颜色\n由你定义", subtitle: "上百个系统图标 × 十种精选配色", image: "editor", footer: brandFooter),
    Spec(name: "xiaohongshu/xhs-6.png", size: CGSize(width: 1080, height: 1440),
         title: "深色模式\n同样优雅", subtitle: "跟随系统，也支持一键切换", image: "panel-list-dark", footer: brandFooter),

    // LinkedIn 1200×627
    Spec(name: "linkedin/li-1.png", size: CGSize(width: 1200, height: 627),
         title: "LiteCount", subtitle: "A lightweight countdown for your important moments", image: "panel-list", footer: brandFooter),
    Spec(name: "linkedin/li-2.png", size: CGSize(width: 1200, height: 627),
         title: "Glanceable by design", subtitle: "Days, hours, minutes, seconds — always ticking", image: "panel-list", footer: brandFooter),
    Spec(name: "linkedin/li-3.png", size: CGSize(width: 1200, height: 627),
         title: "Create in seconds", subtitle: "Name, target time, icon and color", image: "editor", footer: brandFooter),
    Spec(name: "linkedin/li-4.png", size: CGSize(width: 1200, height: 627),
         title: "One combined picker", subtitle: "Calendar and time on a single sheet", image: "date-picker", footer: brandFooter),
    Spec(name: "linkedin/li-5.png", size: CGSize(width: 1200, height: 627),
         title: "Make it yours", subtitle: "System icons × curated colors", image: "editor", footer: brandFooter),
    Spec(name: "linkedin/li-6.png", size: CGSize(width: 1200, height: 627),
         title: "Beautiful in the dark", subtitle: "Light and dark mode, both first-class", image: "panel-list-dark", footer: brandFooter),

    // X 1200×675
    Spec(name: "x/x-1.png", size: CGSize(width: 1200, height: 675),
         title: "LiteCount", subtitle: "A lightweight desktop countdown for macOS", image: "panel-list", footer: brandFooter),
    Spec(name: "x/x-2.png", size: CGSize(width: 1200, height: 675),
         title: "Create in seconds", subtitle: "Name · target time · icon · color", image: "editor", footer: brandFooter),
    Spec(name: "x/x-3.png", size: CGSize(width: 1200, height: 675),
         title: "One combined picker", subtitle: "Calendar and time on a single sheet", image: "date-picker", footer: brandFooter),
    Spec(name: "x/x-4.png", size: CGSize(width: 1200, height: 675),
         title: "Beautiful in the dark", subtitle: "Light and dark mode, both first-class", image: "panel-list-dark", footer: brandFooter),
]

let appBlue = NSColor(calibratedRed: 9 / 255, green: 118 / 255, blue: 229 / 255, alpha: 1)

struct CardView: View {
    let spec: Spec

    private var pad: CGFloat { spec.size.height > 1000 ? 72 : (spec.size.height < 300 ? 20 : 44) }
    private var imageHeight: CGFloat {
        spec.size.height > 1000 ? spec.size.height * 0.58
            : (spec.size.height < 300 ? spec.size.height - 2 * pad : spec.size.height * 0.52)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(nsColor: NSColor(calibratedRed: 0.92, green: 0.95, blue: 1.0, alpha: 1)),
                         Color(nsColor: NSColor(calibratedRed: 0.97, green: 0.98, blue: 1.0, alpha: 1))],
                startPoint: .top, endPoint: .bottom
            )
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: spec.size.height * 0.9)
                .offset(x: spec.size.width * 0.42, y: -spec.size.height * 0.35)
            Circle()
                .fill(Color(nsColor: appBlue).opacity(0.10))
                .frame(width: spec.size.height * 0.7)
                .offset(x: -spec.size.width * 0.45, y: spec.size.height * 0.4)

            VStack(alignment: .leading, spacing: 0) {
                if !spec.title.isEmpty {
                    Text(spec.title)
                        .font(.system(size: spec.size.height > 1000 ? 72 : 44, weight: .bold))
                        .foregroundStyle(Color(nsColor: NSColor(calibratedRed: 0.04, green: 0.23, blue: 0.47, alpha: 1)))
                        .lineSpacing(6)
                }
                if !spec.subtitle.isEmpty {
                    Text(spec.subtitle)
                        .font(.system(size: spec.size.height > 1000 ? 34 : 22, weight: .medium))
                        .foregroundStyle(Color(nsColor: NSColor(calibratedRed: 0.25, green: 0.36, blue: 0.5, alpha: 1)))
                        .padding(.top, spec.size.height > 1000 ? 18 : 10)
                }
                if let name = spec.image, let image = loadShot(name) {
                    ScreenshotView(image: image)
                        .frame(width: spec.size.width - 2 * pad, height: imageHeight, alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: spec.size.height > 1000 ? 28 : 18, style: .continuous))
                        .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
                        .padding(.top, spec.size.height > 1000 ? 40 : 20)
                }
                if !spec.footer.isEmpty {
                    Text(spec.footer)
                        .font(.system(size: spec.size.height > 1000 ? 26 : 16, weight: .semibold))
                        .foregroundStyle(Color(nsColor: appBlue))
                        .padding(.top, spec.size.height > 1000 ? 28 : 16)
                }
            }
            .padding(pad)
        }
        .frame(width: spec.size.width, height: spec.size.height)
        .clipped()
    }
}

func loadShot(_ name: String) -> NSImage? {
    let url = captures.appendingPathComponent("\(name).png")
    guard let image = NSImage(contentsOf: url) else {
        print("MISSING screenshot: \(url.path)")
        return nil
    }
    return image
}

struct ScreenshotView: View {
    let image: NSImage

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fill)
    }
}

func render(_ spec: Spec) throws {
    let host = NSHostingView(rootView: CardView(spec: spec))
    host.frame = NSRect(origin: .zero, size: spec.size)
    host.layoutSubtreeIfNeeded()
    host.displayIfNeeded()

    let scale: CGFloat = 2
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(spec.size.width * scale),
        pixelsHigh: Int(spec.size.height * scale),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    bitmap.size = spec.size
    host.cacheDisplay(in: host.bounds, to: bitmap)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "render", code: 1)
    }
    let url = out.appendingPathComponent(spec.name)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
    print("rendered \(spec.name)")
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
for spec in specs {
    try render(spec)
}
print("ALL_CARDS_DONE")
