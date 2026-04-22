#!/usr/bin/env swift
import AppKit

let iconset = "AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconset)
try fm.createDirectory(atPath: iconset, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

func renderIcon(size: CGFloat) -> NSBitmapImageRep {
    let pixelSize = Int(size)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 32
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let corner = size * 0.225
    let bg = NSBezierPath(roundedRect: rect, xRadius: corner, yRadius: corner)
    bg.addClip()

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.32, green: 0.55, blue: 0.98, alpha: 1),
        NSColor(calibratedRed: 0.10, green: 0.26, blue: 0.76, alpha: 1),
    ])!
    gradient.draw(in: rect, angle: 270)

    let pointSize = size * 0.62
    let symConfig = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        .applying(NSImage.SymbolConfiguration(hierarchicalColor: .white))
    if let globe = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)?
        .withSymbolConfiguration(symConfig) {
        let s = globe.size
        let drawRect = NSRect(
            x: (size - s.width) / 2,
            y: (size - s.height) / 2,
            width: s.width,
            height: s.height
        )
        globe.draw(in: drawRect)
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

for (name, size) in sizes {
    let rep = renderIcon(size: size)
    guard let data = rep.representation(using: .png, properties: [:]) else { continue }
    let url = URL(fileURLWithPath: "\(iconset)/\(name)")
    try data.write(to: url)
    print("  • \(name) (\(Int(size))px)")
}

print("✓ Generated \(iconset)")
